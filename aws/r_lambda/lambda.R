# lambda.R

library(jsonlite)

# Read the event from stdin
event <- fromJSON(file("stdin"))

# Log the event
cat("Received event:\n")
print(event)

# Create a response
response <- list(
  statusCode = 200,
  body = toJSON(list(message = "Hello from R Lambda!"))
)

# Write the response to stdout
write(toJSON(response, auto_unbox = TRUE), stdout())
