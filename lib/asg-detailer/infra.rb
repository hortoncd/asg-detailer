require 'aws-sdk-ec2'
require 'aws-sdk-elasticloadbalancing'
require 'aws-sdk-autoscaling'

module AsgDetailer
  class Infra
    def initialize
      @asg = nil
    end

    def query_asg(name)
      # we save the asg because it's used more than once
      @asg = Aws::AutoScaling::Client.new
      @asg.describe_auto_scaling_groups ({
        auto_scaling_group_names: [
          name,
        ],
      })
    end

    def query_lc(name)
      @asg.describe_launch_configurations({
        launch_configuration_names: [
          name,
        ],
      })
    end

    def query_instance_health(name)
      elb = Aws::ElasticLoadBalancing::Client.new
      elb.describe_instance_health({load_balancer_name: name})
    end

    def query_instances(ids)
      ec2 = Aws::EC2::Client.new
      ec2.describe_instances({ instance_ids: ids })
    end
  end
end
