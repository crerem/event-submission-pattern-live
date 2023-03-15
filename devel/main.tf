
/*
*
*  Api Gateway
* 
*/

module "api-gateway" {
  source                 = "../modules/api-gateway"
  ENVIROMENT             = var.ENV
  APP_NAME               = var.APP_NAME
  MAIN_LAMBDA_INVOKE_ARN = module.main-lambda.main_lambda_invoke_arn
  SQS_URI                = module.simple-queque-service.sg12-simple_queque_url
  SQS_NAME               = module.simple-queque-service.sg12-simple_queque_name
  SQS_ARN                = module.simple-queque-service.sg12-simple_queque_arn
  AWS_REGION             = var.AWS_REGION

}


/*
*
*  Sqs 
* 
*/

module "simple-queque-service" {
  source     = "../modules/simple-queque-service"
  ENVIROMENT = var.ENV
  APP_NAME   = var.APP_NAME
}

/*
*
*  Main Lamnda function
* 
*/
module "main-lambda" {
  source            = "../modules/main-lambda"
  FUNCTION_NAME     = "${var.APP_NAME}-${var.ENV}-lambda-function"
  APP_NAME          = var.APP_NAME
  SQS_ARN           = module.simple-queque-service.sg12-simple_queque_arn
  API_EXECUTION_ARN = module.api-gateway.sg12_rest_api_execution_arn
  STEP_FUNCTION_ARN = module.step-function.step_function_arn
}



/*
*
*  Step Functions
* 
*/

module "step-function" {
  source                    = "../modules/step-function"
  ENVIROMENT                = var.ENV
  APP_NAME                  = var.APP_NAME
  PROCESSING_LAMBDA_ARN     = module.processing-lambda.processing_lamnbda_arn
  SAVE_TO_DYNOMO_LAMBDA_ARN = module.save-to-dynamo-lambda.save_to_dynomo_lambda_arn
  SNS_ARN                   = module.simple-notification-service.sns_topic
}



/*
*
*  SNS 
* 
*/

module "simple-notification-service" {
  source     = "../modules/simple-notification-service"
  ENVIROMENT = var.ENV
  APP_NAME   = var.APP_NAME
}



/*
*
*  SNS 
* 
*/

module "dynamo" {
  source     = "../modules/dynomo"
  ENVIROMENT = var.ENV
  APP_NAME   = var.APP_NAME
}


/*
*
*  Save to Dynamo Lamnda function
* 
*/
module "save-to-dynamo-lambda" {
  source            = "../modules/save-to-dynamo-lambda"
  FUNCTION_NAME     = "SG12_save-to-dynamo-lambda"
  APP_NAME          = var.APP_NAME
  DYNANO_DB         = module.dynamo.dynamo_db_arn
  DYNAMO_TABLE_NAME = module.dynamo.dynomo_table_name

}

/*
*
*  Save to Dynamo Lamnda function
* 
*/
module "processing-lambda" {
  source        = "../modules/processing-lambda"
  FUNCTION_NAME = "SG12_processing-lambda"
  APP_NAME      = var.APP_NAME

}