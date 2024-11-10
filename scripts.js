document.addEventListener("DOMContentLoaded", () => {
    const apiGatewayEndpoint = "https://API_ID.execute-api.REGION.amazonaws.com/visitor";

    fetch(apiGatewayEndpoint)
        .then(response => response.json())
        .then(data => {
            document.getElementById("visitor-count").innerText = `Visitors: ${data.visitor_count}`;
        })
        .catch(error => console.error("Error fetching visitor count:", error));
});
