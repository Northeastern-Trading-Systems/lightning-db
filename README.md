# lightning-db
db to integrate with trader interface.

# Guide on how to run this project:

Step 1: Start docker on your device

Step 2: Navigate to lightning-db in a terminal.

Step 3: type 'docker compose build'

Step 4: after the containers are build, type 'docker compose up'

Step 5: navigate to the top of the log that started printing after you composed up and locate the '* Running on http:.......' entry.
- If this entry appears, you can now use the demo environment in your browser.

Step 6 (optional): you can use an application called ngrok that will give you uniquely generated http & https addresses for running dev applications locally.
- Open a new terminal.
- Type ngrok http 8001 (because this is the port we chose to serve in the docker-compose.yml file)

Step 7: in your browser, paste the ngrok https link that you were given.
- It is normal to see a warning message and 'visit site' button when doing this in chrome.

Step 8: if successful, you will see a short message and you can now start hitting endpoints.
- Type '<link>/strategy/get_strategy_status/BullBreakout' to get strategy info for the bullbreakout strategy.