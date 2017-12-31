<?php
/**
 * PLugin Name:  Mailcatcher implementation for Wordpress as MU plugin for travis tests
 */

add_action('phpmailer_init', function (PHPMailer $phpmailer){
    $phpmailer->Host = 'mailcatcher';
    $phpmailer->Port = "1025";
    $phpmailer->SMTPAuth = false;
    $phpmailer->isSMTP();
});