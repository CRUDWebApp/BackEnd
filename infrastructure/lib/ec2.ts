import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import { Construct } from 'constructs';

export interface EC2ConstructProps {
    vpc: ec2.Vpc,
}


export class EC2Construct extends Construct {
    public readonly instance: ec2.Instance;

    constructor(scope: Construct, id:  string, props: EC2ConstructProps){
        super(scope, id)

        // security group
        const SecurityGroup = new ec2.SecurityGroup(this, 'EC2SecurityGroup', {
            vpc: props.vpc,
            allowAllOutbound: true,
            securityGroupName: 'EC2-Security-Group'
        });

        //SSH
        SecurityGroup.addIngressRule(
            ec2.Peer.anyIpv4(),
            ec2.Port.tcp(22),
            'Allow SSH'
        );

        const keypair = new ec2.KeyPair(this, 'KeyPair', {
            type: ec2.KeyPairType.ED25519,
            format: ec2.KeyPairFormat.PEM
        })

        //EC2 instane
        this.instance = new ec2.Instance(this, 'WebServerInstance',{
            vpc: props.vpc,
            instanceType: new ec2.InstanceType('t3.micro'),
            machineImage: ec2.MachineImage.latestAmazonLinux2023(),
            vpcSubnets: 
            {
                subnetType: ec2.SubnetType.PUBLIC
            },
            securityGroup: SecurityGroup,
            keyPair: keypair
        });

        new cdk.CfnOutput(this, 'EC2PublicIP', {
            value: this.instance.instancePublicIp,
            exportName: 'ec2-public-ip'
        })

        new cdk.CfnOutput(this, 'EC2PrivateKey', {
            value: keypair.keyPairId
        })
    }
}