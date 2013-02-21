# CUSTOM _mR 
#
# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
#
 
# TODO: Update internal subnet ACL and security.
 
# Define the internal network subnet.
# These are used below to allow internal access to certain files while not
# allowing access from the public internet.
# acl internal {
#  "192.10.0.0"/24;
# }
 
# Default backend definition.  Set this to point to your content
# server.
#
backend default {
  .host = "127.0.0.1";
  .port = "8080";
}
 
# Respond to incoming requests.
sub vcl_recv {
  # Use anonymous, cached pages if all backends are down.
  if (!req.backend.healthy) {
    unset req.http.Cookie;
  }
 
  # Allow the backend to serve up stale content if it is responding slowly.
  set req.grace = 6h;
 
  # Pipe these paths directly to Apache for streaming.
  #if (req.url ~ "^/admin/content/backup_migrate/export") {
  #  return (pipe);
  #}
 
  # Do not cache these paths.
  if (req.url ~ "^/status\.php$" ||
      req.url ~ "^/update\.php$" ||
      req.url ~ "^/admin$" ||
      req.url ~ "^/admin/.*$" ||
      req.url ~ "^/flag/.*$" ||
      req.url ~ "^.*/ajax/.*$" ||
      req.url ~ "^.*/ahah/.*$") {
       return (pass);
  }
 
  # Do not allow outside access to cron.php or install.php.
  #if (req.url ~ "^/(cron|install)\.php$" && !client.ip ~ internal) {
    # Have Varnish throw the error directly.
  #  error 404 "Page not found.";
    # Use a custom error page that you've defined in Drupal at the path "404".
    # set req.url = "/404";
  #}
 
  # Always cache the following file types for all users. This list of extensions
  # appears twice, once here and again in vcl_fetch so make sure you edit both
  # and keep them equal.
  if (req.url ~ "(?i)\.(pdf|asc|dat|txt|doc|xls|ppt|tgz|csv|png|gif|jpeg|jpg|ico|swf|css|js)(\?.*)?$") {
    unset req.http.Cookie;
  }
 
  # Remove all cookies that Drupal doesn't need to know about. We explicitly 
  # list the ones that Drupal does need, the SESS and NO_CACHE. If, after 
  # running this code we find that either of these two cookies remains, we 
  # will pass as the page cannot be cached.
  if (req.http.Cookie) {
    # 1. Append a semi-colon to the front of the cookie string.
    # 2. Remove all spaces that appear after semi-colons.
    # 3. Match the cookies we want to keep, adding the space we removed 
    #    previously back. (\1) is first matching group in the regsuball.
    # 4. Remove all other cookies, identifying them by the fact that they have
    #    no space after the preceding semi-colon.
    # 5. Remove all spaces and semi-colons from the beginning and end of the 
    #    cookie string. 
    set req.http.Cookie = ";" + req.http.Cookie;
    set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");    
    set req.http.Cookie = regsuball(req.http.Cookie, ";(SESS[a-z0-9]+|SSESS[a-z0-9]+|NO_CACHE)=", "; \1=");
    set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
    set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");
 
    if (req.http.Cookie == "") {
      # If there are no remaining cookies, remove the cookie header. If there
      # aren't any cookie headers, Varnish's default behavior will be to cache
      # the page.
      unset req.http.Cookie;
    }
    else {
      # If there is any cookies left (a session or NO_CACHE cookie), do not
      # cache the page. Pass it on to Apache directly.
      return (pass);
    }
  }
}
 
# Set a header to track a cache HIT/MISS.
sub vcl_deliver {
  if (obj.hits > 0) {
    set resp.http.X-Varnish-Cache = "HIT";
  }
  else {
    set resp.http.X-Varnish-Cache = "MISS";
  }
}
 
# Code determining what to do when serving items from the Apache servers.
# beresp == Back-end response from the web server.
sub vcl_fetch {
  # We need this to cache 404s, 301s, 500s. Otherwise, depending on backend but 
  # definitely in Drupal's case these responses are not cacheable by default.
  if (beresp.status == 404 || beresp.status == 301 || beresp.status == 500) {
    set beresp.ttl = 10m;
  }
 
  # Don't allow static files to set cookies. 
  # (?i) denotes case insensitive in PCRE (perl compatible regular expressions).
  # This list of extensions appears twice, once here and again in vcl_recv so 
  # make sure you edit both and keep them equal.
  if (req.url ~ "(?i)\.(pdf|asc|dat|txt|doc|xls|ppt|tgz|csv|png|gif|jpeg|jpg|ico|swf|css|js)(\?.*)?$") {
    unset beresp.http.set-cookie;
  }
 
  # Allow items to be stale if needed.
  set beresp.grace = 6h;
}
 
# In the event of an error, show friendlier messages.
sub vcl_error {
  # Redirect to some other URL in the case of a homepage failure.
  #if (req.url ~ "^/?$") {
  #  set obj.status = 302;
  #  set obj.http.Location = "http://backup.example.com/";
  #}
 
  # Otherwise redirect to the homepage, which will likely be in the cache.
  set obj.http.Content-Type = "text/html; charset=utf-8";
  synthetic {"
<html>
<head>
  <title>Page Unavailable</title>
  <style>
    body { background: #303030; text-align: center; color: white; }
    #page { border: 1px solid #CCC; width: 500px; margin: 100px auto 0; padding: 30px; background: #323232; }
    a, a:link, a:visited { color: #CCC; }
    .error { color: #222; }
  </style>
</head>
<body onload="setTimeout(function() { window.location = '/' }, 5000)">
  <div id="page">
    <h1 class="title">Page Unavailable</h1>
    <p>The page you requested is temporarily unavailable.</p>
    <p>We're redirecting you to the <a href="/">homepage</a> in 5 seconds.</p>
    <div class="error">(Error "} + obj.status + " " + obj.response + {")</div>
  </div>
</body>
</html>
"};
  return (deliver);
}