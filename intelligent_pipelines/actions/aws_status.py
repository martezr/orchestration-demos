import json
import random

from st2common.runners.base_action import Action

class MyEchoAction(Action):
    def run(self, aws_health):

        services = ["ec2","iam","kms","s3"]
        status_json = {}
        unhealthy_service = random.choice(services)

        if aws_health == "healthy":
            unhealthy_service = "none"

        for service in services:
            if service == unhealthy_service:
                status_json[service] = "unhealty"
            else:
                status_json[service] = "healthy"

        if aws_health == "healthy":
	    return (True, json.dumps(status_json))
        else:
            return (False, json.dumps(status_json))
