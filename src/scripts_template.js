document.addEventListener("DOMContentLoaded", () => {
    const apiGatewayEndpoint = "https://${api_id}.execute-api.${region}.amazonaws.com/visitor";

    fetch(apiGatewayEndpoint)
        .then(response => response.json())
        .then(responseData => {  // This is a regular variable, so no ${} needed
            document.getElementById("visitor-count").innerText = `Visitors: ${responseData.visitor_count}`;
        })
        .catch(error => console.error("Error fetching visitor count:", error));
});
