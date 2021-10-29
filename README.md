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

### Quickstart

1. git clone [repository clone url]
2. cd [respository name]
3. ...

## Demo

A demo app is included to show how to use the project.

To run the demo, follow these steps:

(Add steps to start up the demo)

1.
2.
3.

## Resources

(Any additional resources or related projects)

- Link to supporting information
- Link to similar sample
- ...
