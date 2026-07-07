import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";

import { VPCConstruct } from "./vpc";
import { EC2Construct } from "./ec2";
import { ECRConstruct } from "./ecr";

export class WebAppStack extends cdk.Stack {
    constructor(scope: Construct, id: string, props?: cdk.StackProps){
        super(scope, id, props);

        const vpc_test = new VPCConstruct(this, 'VPC-test',{
            VPCName: 'VPC-test'
        });

        new EC2Construct(this,'EC2-test', {
            vpc: vpc_test.vpc,
        });
        
    }
}
export class ECRStack extends cdk.Stack {
    constructor(scope: Construct, id: string, props?: cdk.StackProps){
        super(scope, id, props);
        new ECRConstruct(this, 'ECR-test');
    }
}