require 'simplecov'
SimpleCov.profiles.define 'no_vendor_coverage' do
  add_filter 'vendor' # Don't include vendored stuff
end

# save to CircleCI's artifacts directory if we're on CircleCI
if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], 'coverage')
  SimpleCov.coverage_dir(dir)
end

SimpleCov.start 'no_vendor_coverage'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'asg-detailer'

def aws_test_vars
  asg_name = 'test-asg'
  lc_name = 'test-lc'
  lb_name = 'test-lb'

  test_vars = Hash.new
  test_vars[:asg_name] = asg_name
  test_vars[:lc_name] = lc_name
  test_vars[:lb_name] = lb_name
  test_vars[:instance_ids] = ['i-00000000000000000', 'i-00000000000000001', 'i-00000000000000002', 'i-00000000000000003']

  test_vars[:asg_resp] = {
    "auto_scaling_groups": [
      {
      "name": "test-asg",
        "min_size": 0,
        "max_size": 3,
        "desired_capacity": 3,
        "subnets": "subnet-00000000,subnet-11111111,subnet-22222222",
        "lc": {
          "name": "test-lc",
          "instance_type": "t2.micro",
          "image_id": "ami-00000000",
          "security_groups": [
            "sg-00000000"
          ]
        },
        "instances": {
          "i-00000000000000000": {
            "ip": "10.0.0.1",
            "image_id": "ami-00000000"
          },
          "i-00000000000000001": {
            "ip": "10.0.0.99",
            "image_id": "ami-00000000"
          },
          "i-00000000000000002": {
            "ip": "10.0.0.199",
            "image_id": "ami-00000000"
          },
          "i-00000000000000003": {
            "ip": "IP is N/A",
            "image_id": "ami-00000000"
          }
        },
        "load_balancers": {
          "test-lb": {
            "i-00000000000000000": {
              "state": "InService"
            },
            "i-00000000000000002": {
              "state": "OutOfService"
            }
          }
        }
      }
    ]
  }

  test_vars[:asg_resp_no_lc] = {
    "auto_scaling_groups": [
      {
      "name": "test-asg",
        "min_size": 0,
        "max_size": 3,
        "desired_capacity": 3,
        "subnets": "subnet-00000000,subnet-11111111,subnet-22222222",
        "lc": {
          "name": "N/A",
          "instance_type": "N/A",
          "image_id": "N/A",
          "security_groups": "N/A"
        },
        "instances": {
          "i-00000000000000000": {
            "ip": "10.0.0.1",
            "image_id": "ami-00000000"
          },
          "i-00000000000000001": {
            "ip": "10.0.0.99",
            "image_id": "ami-00000000"
          },
          "i-00000000000000002": {
            "ip": "10.0.0.199",
            "image_id": "ami-00000000"
          },
          "i-00000000000000003": {
            "ip": "IP is N/A",
            "image_id": "ami-00000000"
          }
        },
        "load_balancers": {
          "test-lb": {
            "i-00000000000000000": {
              "state": "InService"
            },
            "i-00000000000000002": {
              "state": "OutOfService"
            }
          }
        }
      }
    ]
  }

  test_vars[:asg_resp_no_lb] =  {
    "auto_scaling_groups": [
       {
         "name": asg_name,
         "min_size": 0,
         "max_size": 3,
         "desired_capacity": 3,
         "subnets": "subnet-00000000,subnet-11111111,subnet-22222222",
         "lc": {
           "name": lc_name,
           "instance_type": "t2.micro",
           "image_id": "ami-00000000",
           "security_groups": ["sg-00000000"]
         },
         "instances": {
           "i-00000000000000000": {
             "ip": "10.0.0.1",
             "image_id": "ami-00000000"
           },
           "i-00000000000000001": {
             "ip": "10.0.0.99",
             "image_id": "ami-00000000"
           },
           "i-00000000000000002": {
             "ip": "10.0.0.199",
             "image_id": "ami-00000000"
           },
           "i-00000000000000003": {
             "ip": "IP is N/A",
             "image_id": "ami-00000000"
           }
         },
         "load_balancers": {}
      }
    ]
  }

  test_vars[:asg_resp_no_lb_or_inst] = {
    "auto_scaling_groups": [
       {
         "name": asg_name,
         "min_size": 0,
         "max_size": 3,
         "desired_capacity": 3,
         "subnets": "subnet-00000000,subnet-11111111,subnet-22222222",
         "lc": {
           "name": lc_name,
           "instance_type": "t2.micro",
           "image_id": "ami-00000000",
           "security_groups": ["sg-00000000"]
         },
         "instances": {},
         "load_balancers": {}
      }
    ]
  }

  test_vars[:asg_resp_ip_missing] = {
    "auto_scaling_groups": [
      {
        "name": "test-asg",
        "min_size": 0,
        "max_size": 3,
        "desired_capacity": 3,
        "subnets": "subnet-00000000,subnet-11111111,subnet-22222222",
        "lc": {
          "name": "test-lc",
          "instance_type": "t2.micro",
          "image_id": "ami-00000000",
          "security_groups": [
            "sg-00000000"
          ]
        },
        "instances": {
          "i-00000000000000000": {
            "ip": "10.0.0.1",
            "image_id": "ami-00000000"
          },
          "i-00000000000000001": {
            "ip": "IP is N/A",
            "image_id": "ami-00000000"
          },
          "i-00000000000000002": {
            "ip": "10.0.0.199",
            "image_id": "ami-00000000"
          },
          "i-00000000000000003": {
            "ip": "IP is N/A",
            "image_id": "ami-00000000"
          }
        },
        "load_balancers": {
          "test-lb": {
            "i-00000000000000000": {
              "state": "InService"
            },
            "i-00000000000000002": {
              "state": "OutOfService"
            }
          }
        }
      }
    ]
  }

  test_vars[:asg_output] = "Autoscaling Group: #{asg_name}
min size: 0
max size: 3
desired capacity: 3
subnets: subnet-00000000,subnet-11111111,subnet-22222222

Launch Configuration: #{lc_name}
instance type: t2.micro
AMI: ami-00000000
security groups: [\"sg-00000000\"]

Instances:
  InstanceID: i-00000000000000000 : ami-00000000 : 10.0.0.1
  InstanceID: i-00000000000000001 : ami-00000000 : 10.0.0.99
  InstanceID: i-00000000000000002 : ami-00000000 : 10.0.0.199
  InstanceID: i-00000000000000003 : ami-00000000 : IP is N/A

Load Balancer: #{lb_name}
  Instances:
    InstanceID: i-00000000000000000 : 10.0.0.1 : InService
    InstanceID: i-00000000000000002 : 10.0.0.199 : OutOfService\n"

  test_vars[:asg_output_no_lc] = "Autoscaling Group: #{asg_name}
min size: 0
max size: 3
desired capacity: 3
subnets: subnet-00000000,subnet-11111111,subnet-22222222

Launch Configuration: N/A
instance type: N/A
AMI: N/A
security groups: N/A

Instances:
  InstanceID: i-00000000000000000 : ami-00000000 : 10.0.0.1
  InstanceID: i-00000000000000001 : ami-00000000 : 10.0.0.99
  InstanceID: i-00000000000000002 : ami-00000000 : 10.0.0.199
  InstanceID: i-00000000000000003 : ami-00000000 : IP is N/A

Load Balancer: #{lb_name}
  Instances:
    InstanceID: i-00000000000000000 : 10.0.0.1 : InService
    InstanceID: i-00000000000000002 : 10.0.0.199 : OutOfService\n"

  test_vars[:asg_output_no_lb] = "Autoscaling Group: #{asg_name}
min size: 0
max size: 3
desired capacity: 3
subnets: subnet-00000000,subnet-11111111,subnet-22222222

Launch Configuration: #{lc_name}
instance type: t2.micro
AMI: ami-00000000
security groups: [\"sg-00000000\"]

Instances:
  InstanceID: i-00000000000000000 : ami-00000000 : 10.0.0.1
  InstanceID: i-00000000000000001 : ami-00000000 : 10.0.0.99
  InstanceID: i-00000000000000002 : ami-00000000 : 10.0.0.199
  InstanceID: i-00000000000000003 : ami-00000000 : IP is N/A\n"

  test_vars[:asg_output_no_lb_or_inst] = "Autoscaling Group: #{asg_name}
min size: 0
max size: 3
desired capacity: 3
subnets: subnet-00000000,subnet-11111111,subnet-22222222

Launch Configuration: #{lc_name}
instance type: t2.micro
AMI: ami-00000000
security groups: [\"sg-00000000\"]

Instances:\n"

  test_vars[:asg_output_short] = "Autoscaling Group: #{asg_name}
min size: 0
max size: 3
desired capacity: 3
subnets: subnet-00000000,subnet-11111111,subnet-22222222

Launch Configuration: #{lc_name}
instance type: t2.micro
AMI: ami-00000000
security groups: [\"sg-00000000\"]

Instances:

Load Balancer: #{lb_name}
  Instances:\n"

  return test_vars
end

def aws_stub_vars(test_vars)
  stub_vars = Hash.new
  stub_vars[:instances] = {
    instances_asg: {
      'i-00000000000000000': {
        instance_id: 'i-00000000000000000',
        availability_zone: 'us-west-2a',
        lifecycle_state: 'InService',
        health_status: 'Healthy',
        launch_configuration_name: test_vars[:lc_name],
        protected_from_scale_in: false
      },
      'i-00000000000000001': {
        instance_id: 'i-00000000000000001',
        availability_zone: 'us-west-2b',
        lifecycle_state: 'InService',
        health_status: 'Healthy',
        launch_configuration_name: test_vars[:lc_name],
        protected_from_scale_in: false
      },
      'i-00000000000000002': {
        instance_id: 'i-00000000000000002',
        availability_zone: 'us-west-2c',
        lifecycle_state: 'InService',
        health_status: 'Healthy',
        launch_configuration_name: test_vars[:lc_name],
        protected_from_scale_in: false
      },
      'i-00000000000000003': {
        instance_id: 'i-00000000000000003',
        availability_zone: 'us-west-2b',
        lifecycle_state: 'InService',
        health_status: 'UnHealthy',
        launch_configuration_name: test_vars[:lc_name],
        protected_from_scale_in: false
      }
    },
    instances_detail: {
      'i-00000000000000000': {
        instance_id: 'i-00000000000000000',
        image_id: 'ami-00000000',
        private_ip_address: '10.0.0.1'
      },
      'i-00000000000000001': {
        instance_id: 'i-00000000000000001',
        image_id: 'ami-00000000',
        private_ip_address: '10.0.0.99'
      },
      'i-00000000000000002': {
        instance_id: 'i-00000000000000002',
        image_id: 'ami-00000000',
        private_ip_address: '10.0.0.199'
      },
      'i-00000000000000003': {
        instance_id: 'i-00000000000000003',
        image_id: 'ami-00000000',
        private_ip_address: ''
      }
    },
    instances_detail_ip_missing: {
      'i-00000000000000000': {
        instance_id: 'i-00000000000000000',
        image_id: 'ami-00000000',
        private_ip_address: '10.0.0.1'
      },
      'i-00000000000000001': {
        instance_id: 'i-00000000000000001',
        image_id: 'ami-00000000',
        private_ip_address: nil
      },
      'i-00000000000000002': {
        instance_id: 'i-00000000000000002',
        image_id: 'ami-00000000',
        private_ip_address: '10.0.0.199'
      },
      'i-00000000000000003': {
        instance_id: 'i-00000000000000003',
        image_id: 'ami-00000000',
        private_ip_address: ''
      }
    }
  }

  detailed_instances = Array.new
  test_vars[:instance_ids].each do |i|
    detailed_instances.push stub_vars[:instances][:instances_detail][i.to_sym]
  end
  stub_vars[:instances_hash] = {
    reservations: [
      {
        instances: detailed_instances
      }
    ]
  }

  detailed_instances_ip = Array.new
  test_vars[:instance_ids].each do |i|
    detailed_instances_ip.push stub_vars[:instances][:instances_detail_ip_missing][i.to_sym]
  end
  stub_vars[:instances_hash_ip_missing] = {
    reservations: [
      {
        instances: detailed_instances_ip
      }
    ]
  }

  asg_instances = Array.new
  test_vars[:instance_ids].each do |i|
    asg_instances.push stub_vars[:instances][:instances_asg][i.to_sym]
  end
  stub_vars[:asg_hash] = {
    auto_scaling_groups: [
      {
        auto_scaling_group_name: test_vars[:asg_name],
        launch_configuration_name: test_vars[:lc_name],
        load_balancer_names: [test_vars[:lb_name]],
        min_size: 0,
        max_size: 3,
        desired_capacity: 3,
        default_cooldown: 300,
        availability_zones: ['us-west-2a', 'us-west-2b', 'us-west-2c'],
        health_check_type: 'EC2',
        instances: asg_instances,
        created_time: Time.parse('2016-01-02 20:04:20 UTC'),
        vpc_zone_identifier: 'subnet-00000000,subnet-11111111,subnet-22222222'
      }
    ]
  }
  stub_vars[:asg_hash_no_lc] = {
    auto_scaling_groups: [
      {
        auto_scaling_group_name: test_vars[:asg_name],
        launch_configuration_name: '',
        load_balancer_names: [test_vars[:lb_name]],
        min_size: 0,
        max_size: 3,
        desired_capacity: 3,
        default_cooldown: 300,
        availability_zones: ['us-west-2a', 'us-west-2b', 'us-west-2c'],
        health_check_type: 'EC2',
        instances: asg_instances,
        created_time: Time.parse('2016-01-02 20:04:20 UTC'),
        vpc_zone_identifier: 'subnet-00000000,subnet-11111111,subnet-22222222'
      }
    ]
  }
  stub_vars[:asg_hash_no_lb] = {
    auto_scaling_groups: [
      {
        auto_scaling_group_name: test_vars[:asg_name],
        launch_configuration_name: test_vars[:lc_name],
        load_balancer_names: [],
        min_size: 0,
        max_size: 3,
        desired_capacity: 3,
        default_cooldown: 300,
        availability_zones: ['us-west-2a', 'us-west-2b', 'us-west-2c'],
        health_check_type: 'EC2',
        instances: asg_instances,
        created_time: Time.parse('2016-01-02 20:04:20 UTC'),
        vpc_zone_identifier: 'subnet-00000000,subnet-11111111,subnet-22222222'
      }
    ]
  }
  stub_vars[:asg_hash_no_lb_or_inst] = {
    auto_scaling_groups: [
      {
        auto_scaling_group_name: test_vars[:asg_name],
        launch_configuration_name: test_vars[:lc_name],
        load_balancer_names: [],
        min_size: 0,
        max_size: 3,
        desired_capacity: 3,
        default_cooldown: 300,
        availability_zones: ['us-west-2a', 'us-west-2b', 'us-west-2c'],
        health_check_type: 'EC2',
        instances: [],
        created_time: Time.parse('2016-01-02 20:04:20 UTC'),
        vpc_zone_identifier: 'subnet-00000000,subnet-11111111,subnet-22222222'
      }
    ]
  }
  stub_vars[:lc_hash] = {
    launch_configurations: [
      {
        launch_configuration_name: test_vars[:lc_name],
        image_id: 'ami-00000000',
        instance_type: 't2.micro',
        security_groups: ['sg-00000000'],
        created_time: Time.parse('2016-01-02 20:04:15 UTC')
      }
    ]
  }
  stub_vars[:instance_states_hash] = {
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
      },
      {
        instance_id: 'i-00000000000000007',
        state: 'InService',
        reason_code: 'N/A',
        description: 'N/A'
      }
    ]
  }
  return stub_vars
end

# Should probably use fixtures or generate, but this works for now
def setup_aws_stubs
  stub_vars = aws_stub_vars(aws_test_vars)
  Aws.config[:autoscaling] = {
    stub_responses: {
      describe_auto_scaling_groups: stub_vars[:asg_hash],
      describe_launch_configurations: stub_vars[:lc_hash]
    }
  }
  Aws.config[:elasticloadbalancing] = {
    stub_responses: {
      describe_instance_health: stub_vars[:instance_states_hash]
    }
  }
  Aws.config[:ec2] = {
    stub_responses: {
      describe_instances: stub_vars[:instances_hash]
    }
  }
end

def setup_aws_stubs_no_lc
  stub_vars = aws_stub_vars(aws_test_vars)
  Aws.config[:autoscaling] = {
    stub_responses: {
      describe_auto_scaling_groups: stub_vars[:asg_hash_no_lc],
      describe_launch_configurations: nil
    }
  }
end

def setup_aws_stubs_no_lb
  stub_vars = aws_stub_vars(aws_test_vars)
  Aws.config[:autoscaling] = {
    stub_responses: {
      describe_auto_scaling_groups: stub_vars[:asg_hash_no_lb],
      describe_launch_configurations: stub_vars[:lc_hash]
    }
  }
end

def setup_aws_stubs_no_lb_or_inst
  stub_vars = aws_stub_vars(aws_test_vars)
  Aws.config[:autoscaling] = {
    stub_responses: {
      describe_auto_scaling_groups: stub_vars[:asg_hash_no_lb_or_inst],
      describe_launch_configurations: stub_vars[:lc_hash]
    }

  }
end

def setup_aws_stubs_ip_missing
  stub_vars = aws_stub_vars(aws_test_vars)
  Aws.config[:ec2] = {
    stub_responses: {
      describe_instances: stub_vars[:instances_hash_ip_missing]
    }
  }
end
