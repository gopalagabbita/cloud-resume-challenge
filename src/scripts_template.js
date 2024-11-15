document.addEventListener("DOMContentLoaded", () => {
    const apiGatewayEndpoint = "https://${api_id}.execute-api.${region}.amazonaws.com/visitor";

    fetch(apiGatewayEndpoint)
        .then(response => response.json())
        .then(data => {
            document.getElementById("visitor-count").innerText = `Visitors: ${data.visitor_count}`;
        })
        .catch(error => console.error("Error fetching visitor count:", error));
});
