require 'spec_helper'

describe AsgDetailer::Detailer do
  before :each do
    @asg_name = 'test-asg'
    @lc_name = 'test-lc'
    @lb_name = 'test-lb'
    @instance_ids = ['i-00000000000000000', 'i-00000000000000001', 'i-00000000000000002', 'i-00000000000000003']
    setup_aws_stubs(@asg_name, @lc_name, @lb_name, @instance_ids)
    @det = Detailer.new(@asg_name)
  end

  it 'is an instance of AsgDetailer::Detailer' do
    expect(@det).to be_kind_of(AsgDetailer::Detailer)
  end

  it 'sets an asg name from args' do
    expect(@det.name).to eq(@asg_name)
  end

  it 'prints asg detail' do
    asg_output = "Autoscaling Group: #{@asg_name}
min size: 0
max size: 3
desired capacity: 3
subnets: subnet-00000000,subnet-11111111,subnet-22222222

Launch Configuration: #{@lc_name}
instance type: t2.micro
AMI: ami-00000000
security groups: [\"sg-00000000\"]

Load Balancer: #{@lb_name}
  Instances:
    InstanceID: i-00000000000000000 : 10.0.0.1 : InService
    InstanceID: i-00000000000000001 : 10.0.0.99 : State is N/A (Not in LB)
    InstanceID: i-00000000000000002 : 10.0.0.199 : OutOfService
    InstanceID: i-00000000000000003 : IP is N/A : State is N/A (Not in LB)\n"

    setup_aws_stubs(@asg_name, @lc_name, @lb_name, @instance_ids)
    expect { @det.run }.to output(asg_output).to_stdout
  end

  it 'prints asg detail without terminated instances' do
    asg_output = "Autoscaling Group: #{@asg_name}
min size: 0
max size: 3
desired capacity: 3
subnets: subnet-00000000,subnet-11111111,subnet-22222222

Launch Configuration: #{@lc_name}
instance type: t2.micro
AMI: ami-00000000
security groups: [\"sg-00000000\"]

Load Balancer: #{@lb_name}
  Instances:
    InstanceID: i-00000000000000000 : 10.0.0.1 : InService
    InstanceID: i-00000000000000001 : 10.0.0.99 : State is N/A (Not in LB)
    InstanceID: i-00000000000000002 : 10.0.0.199 : OutOfService
    InstanceID: i-00000000000000003 : IP is N/A : State is N/A (Not in LB)\n"

    asg_output_short = "Autoscaling Group: #{@asg_name}
min size: 0
max size: 3
desired capacity: 3
subnets: subnet-00000000,subnet-11111111,subnet-22222222

Launch Configuration: #{@lc_name}
instance type: t2.micro
AMI: ami-00000000
security groups: [\"sg-00000000\"]

Load Balancer: #{@lb_name}
  Instances:\n"

    setup_aws_stubs(@asg_name, @lc_name, @lb_name, @instance_ids)
    Aws.config[:ec2] = {
      stub_responses: {describe_instances: 'InvalidInstanceIDNotFound'}
    }
    expect { @det.run }.to_not output(asg_output).to_stdout
    expect { @det.run }.to output(asg_output_short).to_stdout
  end
end
