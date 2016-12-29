require 'spec_helper'

describe AsgDetailer::Infra do
  before :each do
    @asg_name = 'test-asg'
    @lc_name = 'test-lc'
    @lb_name = 'test-lb'
    @instance_ids = ['i-00000000000000000', 'i-00000000000000001', 'i-00000000000000002']
    setup_aws_stubs(@asg_name, @lc_name, @lb_name, @instance_ids)
    @infra = AsgDetailer::Infra.new
  end

  it 'is an instance of AsgDetailer::Infra' do
    expect(@infra).to be_kind_of(AsgDetailer::Infra)
  end

  it 'returns asg details for query of an asg name' do
    resp = @infra.query_asg(@asg_name)
    expect(resp[:auto_scaling_groups].first[:auto_scaling_group_name])
      .to eq(@asg_name)
  end

  it 'returns [] for query of non-existent asg name' do
    Aws.config[:autoscaling] = {
      stub_responses: {
        describe_auto_scaling_groups: []
      }
    }
    resp = @infra.query_asg("missing_name")
    expect(resp[:auto_scaling_groups])
      .to eq([])
  end

  it 'returns lc details from the resulting asg' do
    resp = @infra.query_asg(@asg_name)
    lc = resp[:auto_scaling_groups].first[:launch_configuration_name]
    resp = @infra.query_lc(lc)
    expect(resp[:launch_configurations].first[:launch_configuration_name])
      .to eq(@lc_hash[:launch_configurations].first[:launch_configuration_name])
  end

  it 'queries instance states from elb' do
    resp = @infra.query_instance_health(@lb_name)
    expect(resp[:instance_states].first[:instance_id])
      .to eq(@instance_states_hash[:instance_states].first[:instance_id])
    expect(resp[:instance_states].first[:state])
      .to eq(@instance_states_hash[:instance_states].first[:state])
  end

  it 'queries instance details' do
    resp = @infra.query_instances(@instance_ids)

    expect(resp[:reservations].first[:instances].first[:private_ip_address])
      .to eq(@instances_hash[:reservations].first[:instances].first[:private_ip_address])
    expect(resp[:reservations].first[:instances].first[:instance_id])
      .to eq(@instances_hash[:reservations].first[:instances].first[:instance_id])
    #
  end
end
