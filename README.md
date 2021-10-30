# Automated blue green deployment for Azure Spring Cloud applications

This sample shows how to enable automated blue green deployment for Azure Spring Cloud apps.
The repository contains a sample application and workflows to deploy this application in an automated blue green pattern. The provided sample can be updated for deploying your own Spring Boot application. You can reuse the workflows in the [.github/workflows](.github/workflows) folder.
The sample source code is based on the Azure Architecture Center sample for [Azure Spring Cloud blue green deployment](link still needed).

## Features

This repository provides the following features:

* Repeatable automatic Blue Green deployment workflow for Azure Spring Cloud apps.
* Reusable GitHub Actions workflow for blue green deployment of apps to Azure Spring Cloud service.

## Getting Started

### Prerequisites

- Azure Account
- Azure Spring Cloud service deployed in a resource group in your Azure account (if you don't have one set up, please follow the below guidance for setting up your infrastructure)
- GitHub repository with a Spring Boot app and capability of executing GitHub actions
    - Either copy paste the workflows and [deploy](deploy) folder to your existing repository
    - Or you can fork this repository
    - Or you can start from this templated repository

### Setup the infrastructure

Only execute the below in case you don't have an Azure resource group and Azure Spring Cloud service deployed yet. The below walkthrough also contains the steps needed to set up your deployment secret in your GitHub repository. 
You will need the latest version of the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed to execute these steps.

1. Define environment variables.

```bash
RESOURCE_GROUP='spring-cloud-demos'
LOCATION=westus
```

1. Login to your Azure account and make sure the correct subscription is active. 

```azurecli
az login
az account list -o table
az account set <your-subscription-id>
```

1. Create a resource group for all necessary resources.

```azurecli
az group create --name $RESOURCE_GROUP --location $LOCATION
```

1. Copy the resource group ID which is outputted in the previous step to a new environment variable.

```azurecli
RESOURCE_GROUP_ID=<resource group IP from previous output>
```

1. Create a service principal and give it access to the resource group.

```azure cli
az ad sp create-for-rbac \
  --name SpringCloudGHBicepActionWorkflow \
  --role Contributor \
  --scopes $RESOURCE_GROUP_ID \
  --sdk-auth
```

> [!NOTE]
> In the sample code for the deployment to Azure Spring Cloud service we will reuse this same service principal. However, for a production environment we advise you use a separate service principal with limited scope for deploying your apps to Azure Spring Cloud service.

1. Copy the full output from this command. 

1. In your GitHub repo navigate to *Settings* > *Secrets* and select *New Repository Secret*.

1. Name the secret _AZURE_CREDENTIALS_ and paste the output from the 'az ad sp create-for-rbac' command in the value textbox.

1. Select *Add Secret*.

1. Inspect the [infra-deploy.yml](.github/workflows/infra-deploy.yml) file and update any environment variables at the top of the file to reflect your environment. 

1. In your GitHub repo, navigate to *Actions* and select the *infra-deploy* action. 

1. Select *Run workflow* > *Run workflow*. 

1. This will start a new workflow run and deploy the necessary infrastructure. 

## Workflows in this sample

This sample repository includes 3 sample workflows for deploying applications to Azure Spring Cloud.

### Simple Workflow

The [simple workflow](.github/workflows/simple-deploy.yml) is a workflow you can use for direct deployment to an application in Azure Spring Cloud. It does not include any blue green strategy, but deploys straight to an app. You can use this workflow in case no blue-green zero downtime deployment of your application is needed.

Steps to trigger this workflow: 

1. Make sure you have created a _AZURE_CREDENTIALS_ secret in your GitHub repository for your service principal connection as described in the infrastructure deploy above. 
 
1. Inspect the [simple-deploy.yml](.github/workflows/simple-deploy.yml) file and update any environment variables at the top of the file to reflect your environment. 

1. In your GitHub repo, navigate to *Actions* and select the *simple-deploy* action. 

1. Select *Run workflow* > *Run workflow*. 

1. This will start a new workflow run and deploy your application. 

### Blue Green Workflow

The [blue green workflow](.github/workflows/blue-green-deploy.yml) utilizes a blue green pattern to deploy an application to Azure Spring Cloud with zero downtime. 

This workflow will deploy your application to a new deployment in Azure Spring Cloud. It then makes use of a second job linked to an environment. On the environment you can configure a _required reviewers_ environment protection rule. This will halt the workflow run execution until you have reviewed the new version of the application has deployed correctly, has fully warmed up and can accept production load. Once this is the case, you can approve the workflow to continue its run. This will swap the 2 deployments, making your newly deployed version the production one receiving traffic. It will also delete the previous production deployment. 

Steps to trigger this workflow: 

1. Make sure you have created a _AZURE_CREDENTIALS_ secret in your GitHub repository for your service principal connection as described in the infrastructure deploy above. 

1. Create a new environment _Production_. In your GitHub repository navigate to **Settings** > **Environments** and select the **New environment** button. Fill out **Production** as the name for your environment and select the **Configure environment** button. 

> [!Note]
> In case you want to use a different name for your environment you can do so, the environment is available as a parameter at the top of the workflow file and can be updated to your preference.

1. In the next screen, select the **Required reviewers** checkbox, fill out your own GitHub alias in the textbox as a required reviewer and select the **Save protection rules** button. 

1. Inspect the [blue-green-deploy.yml](.github/workflows/blue-green-deploy.yml) file and update any environment variables at the top of the file to reflect your environment. 

1. In your GitHub repo, navigate to *Actions* and select the *blue-green-deploy* action. 

1. Select *Run workflow* > *Run workflow*. 

1. This will start a new workflow run and deploy your application to a new deployment. The workflow uses 2 deployments it can alternate between: default and green. You can change these names in the environment variables at the top of the workflow. 

1. Once your application has been deployed, you will get an option to either Reject or approve the rest of the workflow run. First navigate to your application in Azure Spring Cloud and inspect whether the new deployment holds the new version of your application and is running correctly. If all looks ok you can approve the further run of your workflow. If not, you can reject, alter your code and redeploy. 

### Blue Green Job and Workflow

The [blue green job](.github/workflows/blue-green-deploy-job.yml) file is a reusable workflow. It is being used by the [blue green deploy using job](.github/workflows/blue-green-deploy-using-job.yml) workflow. Suppose you have multiple applications you would like to deploy to the same Azure Spring Cloud service, for these you can reuse the [blue green job](.github/workflows/blue-green-deploy-job.yml) for each of them.

The reusable workflow will deploy your application to a new deployment in Azure Spring Cloud. It then makes use of a second job linked to an environment. On the environment you can configure a _required reviewers_ environment protection rule. This will halt the workflow run execution until you have reviewed the new version of the application has deployed correctly, has fully warmed up and can accept production load. Once this is the case, you can approve the workflow to continue its run. This will swap the 2 deployments, making your newly deployed version the production one receiving traffic. It will also delete the previous production deployment. 

The reusable workflow is used in the [blue green deploy using job](.github/workflows/blue-green-deploy-using-job.yml) workflow. This wokflow will build the code and will next call the reusable workflow. You will notice inspecting the code that parameters from the top of the file have moved to values directly at the place where the reusable workflow is called. GitHub reusable workflows currently do not support the usage of environment variables when calling a reusable workflow. 

Steps to trigger this workflow: 

1. Make sure you have created a _AZURE_CREDENTIALS_ secret in your GitHub repository for your service principal connection as described in the infrastructure deploy above. 

2. Create a new environment _Production_. In your GitHub repository navigate to **Settings** > **Environments** and select the **New environment** button. Fill out **Production** as the name for your environment and select the **Configure environment** button. 

> [!Note]
> In case you want to use a different name for your environment you can do so, the environment is available as a parameter at the top of the workflow file and can be updated to your preference.

1. In the next screen, select the **Required reviewers** checkbox, fill out your own GitHub alias in the textbox as a required reviewer and select the **Save protection rules** button. 

1. Inspect the [blue-green-deploy-using-job.yml](.github/workflows/blue-green-blue-green-deploy-using-job.yml) file and update any parameters calling the reusable workflow (lines 38 to 42). 

1. In your GitHub repo, navigate to *Actions* and select the *blue-green-deploy-using-job* action. 

1. Select *Run workflow* > *Run workflow*. 

1. This will start a new workflow run and deploy your application to a new deployment. The workflow uses 2 deployments it can alternate between: default and green. You can change these names in the parameters send to the reusable workflow. 

1. Once your application has been deployed, you will get an option to either Reject or approve the rest of the workflow run. First navigate to your application in Azure Spring Cloud and inspect whether the new deployment holds the new version of your application and is running correctly. If all looks ok you can approve the further run of your workflow. If not, you can reject, alter your code and redeploy. 

This workflow can additionally be extended upon to deploy multiple applications at once. 

## Resources

- [Azure Spring Cloud service](https://docs.microsoft.com/azure/spring-cloud/overview)
- [Azure Spring Cloud Deployments](https://docs.microsoft.com/azure/spring-cloud/how-to-staging-environment)
- [Azure Spring Cloud CI/CD](https://docs.microsoft.com/azure/spring-cloud/how-to-github-actions?pivots=programming-language-java)
- [Blue-green deployment strategies](https://docs.microsoft.com/azure/spring-cloud/concepts-blue-green-deployment-strategies)
- [GitHub Actions Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Provision Azure Spring Cloud using Bicep](https://docs.microsoft.com/azure/spring-cloud/quickstart-deploy-infrastructure-vnet-bicep)
- [az spring-cloud app deployment](https://docs.microsoft.com/cli/azure/spring-cloud/app/deployment?view=azure-cli-latest)