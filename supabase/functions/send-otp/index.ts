import { serve } from "https://deno.land/std/http/server.ts";

serve(async (req) => {
  const { phone } = await req.json();

  const accountSid = Deno.env.get("TWILIO_ACCOUNT_SID")!;
  const authToken = Deno.env.get("TWILIO_AUTH_TOKEN")!;
  const serviceSid = Deno.env.get("TWILIO_VERIFY_SERVICE_SID")!;

  const auth = btoa(`${accountSid}:${authToken}`);

  const response = await fetch(
    `https://verify.twilio.com/v2/Services/${serviceSid}/Verifications`,
    {
      method: "POST",
      headers: {
        Authorization: `Basic ${auth}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        To: phone,
        Channel: "sms",
      }),
    }
  );

  const result = await response.text();

  return new Response(result, {
    headers: {
      "Content-Type": "application/json",
    },
  });
});