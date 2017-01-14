require_relative "infra.rb"

include AsgDetailer

module AsgDetailer
  class Detailer
    attr_reader :name

    def initialize(name, options = {})
      @name = name
      @infra = Infra.new
    end

    def run
      detail_asg
    end

    private

    def detail_asg
      resp = @infra.query_asg(@name)

      # should be only one, but returns array...
      resp[:auto_scaling_groups].each do |a|
        puts "Autoscaling Group: #{a[:auto_scaling_group_name]}"
        puts "min size: #{a[:min_size]}"
        puts "max size: #{a[:max_size]}"
        puts "desired capacity: #{a[:desired_capacity]}"
        puts "subnets: #{a[:vpc_zone_identifier]}"

        detail_lc(a[:launch_configuration_name])
        detail_lbs(a)
      end
    end

    def detail_lc(lc)
      puts
      puts "Launch Configuration: #{lc}"

      resp = @infra.query_lc(lc)

      # should be only one, but returns array...
      resp[:launch_configurations].each do |l|
        puts "instance type: #{l[:instance_type]}"
        puts "AMI: #{l[:image_id]}"
        puts "security groups: #{l[:security_groups]}"
      end
    end

    # returns the instance health for any of the instances in the LB
    def detail_lbs(a)
      instance_health = Hash.new
      a[:load_balancer_names].each do |n|
        puts
        puts "Load Balancer: #{n}"

        resp = @infra.query_instance_health(n)
        resp.instance_states.each do |i|
          instance_health[i[:instance_id]] = i[:state]
        end
      end
      detail_instances(a, instance_health)
    end

    def detail_instances(a, instance_health)
      puts "  Instances:"
      ids = []
      a[:instances].map { |i| ids.push i[:instance_id] }

      unless ids.empty?
        resp = @infra.query_instances(ids) 

        resp[:reservations].each do |r|
          r[:instances].each do |i|
            ip = i[:private_ip_address].empty? ? 'IP is N/A' : i[:private_ip_address]
            health = instance_health[i[:instance_id]] ? instance_health[i[:instance_id]] : "State is N/A (Not in LB)"
            puts "    InstanceID: #{i[:instance_id]} : #{ip} : #{health}"
          end
        end
      end
    end
  end
end
