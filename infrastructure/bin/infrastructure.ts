#!/usr/bin/env node

import * as cdk from 'aws-cdk-lib';
import { WebAppStack } from '../lib/infrastructure';

const app = new cdk.App();

new WebAppStack(app, 'WebAppStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});