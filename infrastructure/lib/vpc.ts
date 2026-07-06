import * as cdk from "aws-cdk-lib"
import * as ec2 from "aws-cdk-lib/aws-ec2"
import { Construct } from "constructs"

export interface VPCConstructProps {
    VPCName: string;
}

export class VPCConstruct extends Construct {
    public readonly vpc: ec2.Vpc;
    constructor(scope: Construct, id: string, props: VPCConstructProps) {
        super(scope, id);

        this.vpc = new ec2.Vpc(this, 'WebApp_VPC', {
            vpcName: props.VPCName,
            ipAddresses: ec2.IpAddresses.cidr('10.0.0.0/16'),
            natGateways: 1,
            maxAzs: 2,
            subnetConfiguration: [
                {
                    name: 'public_subnet',
                    subnetType: ec2.SubnetType.PUBLIC,
                    cidrMask: 24
                },
                {
                    name: 'private-subnet',
                    subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,
                    cidrMask: 24,
                }
            ],
            enableDnsHostnames: true,
            enableDnsSupport: true,
        });
        cdk.Tags.of(this.vpc).add('Environment', 'test');
        cdk.Tags.of(this.vpc).add('Project','testing')

        new cdk.CfnOutput(this,'vpcId', {
            value:  this.vpc.vpcId,
            exportName: 'vpcID'
        });

        new cdk.CfnOutput(this, 'PublicSubnetIds', {
            value: this.vpc.publicSubnets.map(s => s.subnetId).join(',')
        });

        new cdk.CfnOutput(this, 'PrivateSubnetIds', {
            value: this.vpc.privateSubnets.map(s => s.subnetId).join(',')
        });
    }
}