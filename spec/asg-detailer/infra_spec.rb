require 'spec_helper'

describe AsgDetailer::Infra do
  before :each do
    @test_vars = aws_test_vars
    @stub_vars = aws_stub_vars(@test_vars)
    setup_aws_stubs
    @infra = AsgDetailer::Infra.new
  end

  it 'is an instance of AsgDetailer::Infra' do
    expect(@infra).to be_kind_of(AsgDetailer::Infra)
  end

  it 'returns asg details for query of an asg name' do
    resp = @infra.query_asg(@test_vars[:asg_name])
    expect(resp[:auto_scaling_groups].first[:auto_scaling_group_name])
      .to eq(@test_vars[:asg_name])
  end

  it 'returns [] for query of non-existent asg name' do
    Aws.config[:autoscaling] = {
      stub_responses: {
        describe_auto_scaling_groups: []
      }
    }
    resp = @infra.query_asg('missing_name')
    expect(resp[:auto_scaling_groups])
      .to eq([])
  end

  it 'returns lc details from the resulting asg' do
    resp = @infra.query_asg(@test_vars[:asg_name])
    lc = resp[:auto_scaling_groups].first[:launch_configuration_name]
    resp = @infra.query_lc(lc)
    expect(resp[:launch_configurations].first[:launch_configuration_name])
      .to eq(@stub_vars[:lc_hash][:launch_configurations].first[:launch_configuration_name])
  end

  it 'queries instance states from elb' do
    resp = @infra.query_instance_health(@test_vars[:lb_name])
    expect(resp[:instance_states].first[:instance_id])
      .to eq(@stub_vars[:instance_states_hash][:instance_states].first[:instance_id])
    expect(resp[:instance_states].first[:state])
      .to eq(@stub_vars[:instance_states_hash][:instance_states].first[:state])
  end

  it 'queries instance details' do
    resp = @infra.query_instances(@test_vars[:instance_ids])

    expect(resp[:reservations].first[:instances].first[:private_ip_address])
      .to eq(@stub_vars[:instances_hash][:reservations].first[:instances].first[:private_ip_address])
    expect(resp[:reservations].first[:instances].first[:instance_id])
      .to eq(@stub_vars[:instances_hash][:reservations].first[:instances].first[:instance_id])
  end

  it 'raises error for bad instance id' do
    Aws.config[:ec2] = {
      stub_responses: {describe_instances: 'InvalidInstanceIDNotFound'}
    }
    expect { @infra.query_instances(['i-11111111']) }
      .to raise_error(Aws::EC2::Errors::InvalidInstanceIDNotFound)
  end
end
