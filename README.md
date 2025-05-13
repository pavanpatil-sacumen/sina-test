## Service Broker

### Pivotal Tile

You are strongly encouraged to use the Pivotal Tile. It has been tested and vetted by Pivotal and it ready for production use. 

### Configuring the Service Broker

To deploy the Service Broker on Pivotal:

1. Install the `cf` cli tool
2. Deploy the application: `cf push contrast-service-broker`
3. Configure environment variables
    * SECURITY_USER_NAME - username used to auth to the application
    * SECURITY_USER_PASSWORD - password used to auth to the application
    * CONTRAST_SERVICE_PLANS - service plans the broker will offer - at least one plan is required!

Example CONTRAST_SERVICE_PLANS:

```json
{"ServicePlan1":{"name":"ServicePlan1","teamserver_url":"https://yourteamserverurl.com","username":"your_username","api_key":"your_api_key","org_uuid":"00000000-1111-2222-3333-000000000000","service_key":"your_service_key"},"ServicePlan2":{"name":"ServicePlan2","teamserver_url":"https://yourteamserverurl.com","username":"your_username","api_key":"your_api_key","org_uuid":"zzzzzzzz-1111-2222-3333-000000000000","service_key":"your_service_key"}}
```

4. Restage the application: `cf restage contrast-service-broker`

5. cf create-service-broker contrast-service-broker USERNAME PASSWORD URL_TO_SERVICE_BROKER_APP

**note** you can get the url for the app by executing `cf apps`

6. cf enable-service-access contrast-security

The application can now be used to provision and bind services.  

If you deploy the application via a Pivotal tile all the above is taken care of for you ✨
