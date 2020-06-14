# Exploring Cognito User Pools
The resources needed are all in the root folder.

See **cognito_user_pool.tf** for cognito resources

See **ses.tf** for simple email service resources

## Notes
* Executing
In order to execute the script you must have terraform installed. For more information take a look at https://www.terraform.io/

* Using **SES**
Add the following to the **cognito_user_pool.tf** at `aws_cognito_user_pool` resource:

```
email_configuration {
  email_sending_account = "DEVELOPER"
  source_arn = "{{SES_EMAIL_ARN}}"
}
```

where the `SES_EMAIL_ARN` is the ARN of the resource created when you execute the **ses.tf** file.