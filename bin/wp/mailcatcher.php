<?php
/**
 * PLugin Name:  Mailcatcher implementation for Wordpress as MU plugin for travis tests
 */
add_action('phpmailer_init', function ($phpmailer) {
    $phpmailer->Host = "127.0.0.1";
    $phpmailer->Port = "1025";
    $phpmailer->SMTPAuth = false;
    $phpmailer->isSMTP();
});