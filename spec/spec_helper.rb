require 'simplecov'
SimpleCov.profiles.define 'no_vendor_coverage' do
    add_filter 'vendor' # Don't include vendored stuff
end

# save to CircleCI's artifacts directory if we're on CircleCI
if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
end

SimpleCov.start 'no_vendor_coverage'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'asg-detailer'

# Should probably use fixtures or generate, but this works for now
def setup_aws_stubs(asg_name, lc_name, lb_name, instance_ids)
  @instances = {
    instances_asg: {
      'i-00000000000000000': {
        instance_id: 'i-00000000000000000',
        availability_zone: "us-west-2a",
        lifecycle_state: "InService",
        health_status: "Healthy",
        launch_configuration_name: lc_name,
        protected_from_scale_in: false
      },
      'i-00000000000000001': {
        instance_id: 'i-00000000000000001',
        availability_zone: "us-west-2b",
        lifecycle_state: "InService",
        health_status: "Healthy",
        launch_configuration_name: lc_name,
        protected_from_scale_in: false
      },
      'i-00000000000000002': {
        instance_id: 'i-00000000000000002',
        availability_zone: "us-west-2c",
        lifecycle_state: "InService",
        health_status: "Healthy",
        launch_configuration_name: lc_name,
        protected_from_scale_in: false
      }
    },
    instances_detail: {
      'i-00000000000000000': {
        instance_id: 'i-00000000000000000',
        private_ip_address: '10.0.0.1'
      },
      'i-00000000000000001': {
        instance_id: 'i-00000000000000001',
        private_ip_address: '10.0.0.99'
      },
      'i-00000000000000002': {
        instance_id: 'i-00000000000000002',
        private_ip_address: '10.0.0.199'
      }
    }
  }

  det_instances = Array.new
  instance_ids.each do |i|
    det_instances.push @instances[:instances_detail][i.to_sym]
  end
  @instances_hash = {
    reservations: [
      {
        instances: det_instances
      }
    ]
  }

  asg_instances = Array.new
  instance_ids.each do |i|
    asg_instances.push @instances[:instances_asg][i.to_sym]
  end
  @asg_hash = {
    auto_scaling_groups: [
      {
        auto_scaling_group_name: asg_name,
        launch_configuration_name: lc_name,
        load_balancer_names: [lb_name],
        min_size: 0,
        max_size: 3,
        desired_capacity: 3,
        default_cooldown: 300,
        availability_zones: ['us-west-2a', 'us-west-2b', 'us-west-2c'],
        health_check_type: 'EC2',
        instances: asg_instances,
        created_time: Time.parse('2016-01-02 20:04:20 UTC'),
        vpc_zone_identifier: "subnet-00000000,subnet-11111111,subnet-22222222"
      }
    ]
  }
  @lc_hash = {
    launch_configurations: [
      {
        launch_configuration_name: lc_name,
        image_id: 'ami-00000000',
        instance_type: 't2.micro',
        security_groups: ['sg-00000000'],
        created_time: Time.parse('2016-01-02 20:04:15 UTC')
      }
    ]
  }
  @instance_states_hash = {
    instance_states: [
      {
        instance_id: 'i-00000000000000000',
        state: 'InService',
        reason_code: 'N/A',
        description: 'N/A'
      },
      {
        instance_id: 'i-00000000000000002',
        state: 'OutOfService',
        reason_code: 'N/A',
        description: 'N/A'
      }
    ]
  }
  Aws.config[:autoscaling] = {
    stub_responses: {
      describe_auto_scaling_groups: @asg_hash,
      describe_launch_configurations: @lc_hash
    }
  }
  Aws.config[:elasticloadbalancing] = {
    stub_responses: {
      describe_instance_health: @instance_states_hash
    }
  }
  Aws.config[:ec2] = {
    stub_responses: {
      describe_instances: @instances_hash
    }
  }
end
