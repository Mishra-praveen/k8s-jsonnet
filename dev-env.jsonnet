local kp = (import "./sample.jsonnet") +
{
    _config: {
        carts: {
            name: "carts",
            image: "weaveworksdemos/carts:0.4.8"
        }
    },
};

//Create deployment manifests
{
    deployment_cart: kp.deployment_cart,
} 
//create service manifests
{
    service_cart: kp.service
}