require_relative 'infra.rb'

include AsgDetailer

module AsgDetailer
  class Detailer
    attr_reader :name
    attr_reader :data

    def initialize(name, options = {})
      @name = name
      @data = nil
      @infra = Infra.new
    end

    def run
      detail_asg
    end

    def print
      self.run
      print_details
    end

    def json
      self.run
      @data ? @data.to_json : nil
    end

    def json_pretty
      self.run
      puts JSON.pretty_generate(@data)
    end

    private

    def detail_asg
      @data ||= Hash.new
      @data[:auto_scaling_groups] = []
      resp = @infra.query_asg(@name)

      # should be only one, but returns array...
      resp[:auto_scaling_groups].each do |a|
        asg = Hash.new
        asg[:name] = a[:auto_scaling_group_name]
        asg[:min_size] = a[:min_size]
        asg[:max_size] = a[:max_size]
        asg[:desired_capacity] = a[:desired_capacity]
        asg[:subnets] = a[:vpc_zone_identifier]
        asg[:lc] = detail_lc(a[:launch_configuration_name])
        asg[:instances] = detail_instances(a)
        asg[:load_balancers] = detail_lbs(a, asg[:instances])
        @data[:auto_scaling_groups] << asg
      end
    end

    def detail_lc(lc)
      lc_hash = {
        name: 'N/A',
        instance_type: 'N/A',
        image_id: 'N/A',
        security_groups: 'N/A'
      }
      unless lc.empty?
        resp = @infra.query_lc(lc)

        # should be only one, but returns array...
        resp[:launch_configurations].each do |l|
          lc_hash[:name] = l[:launch_configuration_name]
          lc_hash[:instance_type] = l[:instance_type]
          lc_hash[:image_id] = l[:image_id]
          lc_hash[:security_groups] = l[:security_groups]
        end
      end
      return lc_hash
    end

    def detail_instances(a)
      instances = Hash.new
      ids = Array.new
      a[:instances].map { |i| ids.push i[:instance_id] }

      unless ids.empty?
        begin
          resp = @infra.query_instances(ids)

          resp[:reservations].each do |r|
            r[:instances].each do |i|
              instance = Hash.new
              if i[:private_ip_address]
                instance[:ip] = i[:private_ip_address].empty? ? 'IP is N/A' : i[:private_ip_address]
              else
                instance[:ip] = 'IP is N/A'
              end
              instance[:image_id] = i[:image_id]
              instances[i[:instance_id]] = instance
            end
          end
        rescue Aws::EC2::Errors::InvalidInstanceIDNotFound
        end
      end
      return instances
    end

    # returns the instance health for any of the instances in the LB
    def detail_lbs(a, instances)
      lbs = Hash.new
      a[:load_balancer_names].each do |n|
        lb = Hash.new
        resp = @infra.query_instance_health(n)
        resp.instance_states.each do |i|
          if instances.has_key?(i[:instance_id])
            lb[i[:instance_id]] = { 'state':  i[:state] }
          end
        end
        lbs[n] = lb
      end
      return lbs
    end

    def print_details
      # should be only one, but returns array...
      @data[:auto_scaling_groups].each do |a|
        puts "Autoscaling Group: #{a[:name]}"
        puts "min size: #{a[:min_size]}"
        puts "max size: #{a[:max_size]}"
        puts "desired capacity: #{a[:desired_capacity]}"
        puts "subnets: #{a[:subnets]}"

        print_lc(a[:lc])
        print_instances(a[:instances])
        print_lbs(a)
      end
    end

    def print_lc(lc)
      puts
      puts "Launch Configuration: #{lc[:name]}"

      puts "instance type: #{lc[:instance_type]}"
      puts "AMI: #{lc[:image_id]}"
      puts "security groups: #{lc[:security_groups]}"
    end

    def print_instances(instances)
      puts
      puts 'Instances:'
      instances.each do |k, v|
        puts "  InstanceID: #{k} : #{v[:image_id]} : #{v[:ip]}"
      end
    end

    # returns the instance health for any of the instances in the LB
    def print_lbs(a)
      a[:load_balancers].each do |k, v|
        puts
        puts "Load Balancer: #{k}"
        print_lb_instances(a, v)
      end
    end

    def print_lb_instances(a, instances)
      puts '  Instances:'
      instances.each do |k, v|
        if a[:instances].has_key?(k)
          puts "    InstanceID: #{k} : #{a[:instances][k][:ip]} : #{v[:state]}"
        end
      end
    end
  end
end
