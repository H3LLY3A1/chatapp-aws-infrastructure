from locust import HttpUser, task, constant

class ChatUser(HttpUser):
    wait_time = constant(0)

    @task
    def backend(self):
        self.client.get("/chat")
