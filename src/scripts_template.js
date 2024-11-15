document.addEventListener("DOMContentLoaded", () => {
    const apiGatewayEndpoint = "https://YOUR_API_GATEWAY_ID.execute-api.YOUR_REGION.amazonaws.com/visitor";

    fetch(apiGatewayEndpoint)
        .then(response => response.json())
        .then(data => {
            document.getElementById("visitor-count").innerText = `Visitors: ${data.visitor_count}`;
        })
        .catch(error => console.error("Error fetching visitor count:", error));
});
