sub run_tests {
    my ($server, $ua) = @_;
    plan tests => 12;

    $ua->get_ok("$server", "got front page");
    $ua->content_contains("hit index", "index controller called - without trailing slash");

    $ua->get_ok("$server/", "got front page");
    $ua->content_contains("hit index", "index controller called - with trailing slash");

    $ua->get_ok("$server/fnord", "got default action");
    $ua->content_contains("hit default", "default controller called, without trailing slash");

    $ua->get_ok("$server/fnord/", "got default action");
    $ua->content_contains("hit default", "default controller called, with trailing slash");

    $ua->get_ok("$server/local_action", "got local_action");
    $ua->content_contains("hit localaction", "local_action controller called, without trailing slash");

    $ua->get_ok("$server/local_action/", "got local_action");
    $ua->content_contains("hit localaction", "local_action controller called, with trailing slash");

}

1;
