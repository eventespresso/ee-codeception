<?php
namespace Helper;

use Codeception\Exception\ModuleException;
use Codeception\Module as CodeCeptionModule;

/**
 * CLI_Actions
 * This provides various handy actor actions that integrate with the WPLI module.
 *
 * @package Helper
 * @author  Darren Ethier
 */
class CLI_Actions extends CodeCeptionModule
{

    /**
     * Checks if a given cron event hook is set.
     *
     * @param string $hook
     * @throws ModuleException
     */
    public function seeCronHookSet($hook)
    {
        $command = 'event list --field=hook';
        $command_result = $this->getModule('WPCLI')->cliToArray($command);
        if ($command_result) {
            $this->assertContains($hook, $command_result);
        } else {
            $this->fail(
                sprintf(
                    'The expected cron event with the hook named %s is not set.',
                    $hook
                )
            );
        }
    }


    /**
     * Use to verify if a the next run timestamp for the given cron event is as expected.
     *
     * @param string $hook
     * @param string $expected_next_run  expected in format YYYY-MM-DD 00:00:00
     * @throws ModuleException
     */
    public function seeCronEventNextRunIsSet($hook, $expected_next_run)
    {
        $command = 'event list --hook=' . $hook . ' --format=json --fields=hook,next_run_gmt';
        $output = array();
        $command_result = $this->getModule('WPCLI')->cli($command, $output);
        if ($command_result) {
            $events = json_decode($output[0]);
            $event = $events[0];
            //should have hook and should have expected_next_run.
            if (empty($event)) {
                $this->fail(
                    sprintf(
                        'The cron event hook named %s is not set.',
                        $hook
                    )
                );
            }
            if ($event->next_run_gmt !== $expected_next_run) {
                $this->fail(
                    sprintf(
                        'The actual next_run schedule was %s.  Expected was %s.',
                        $event->next_run_gmt,
                        $expected_next_run
                    )
                );
            }
        }
    }


    /**
     * Use to verify if the schedule for the given cron event is as expected.
     *
     * @param string $hook
     * @param string $expected_schedule Something like 'daily', 'twicedaily', or any custom schedule identifier setup.
     * @throws ModuleException
     */
    public function seeCronEventScheduleIsSet($hook, $expected_schedule) {
        $command = 'event list --hook=' . $hook . ' --format=json --fields=hook,schedule';
        $output = array();
        $command_result = $this->getModule('WPCLI')->cli($command, $output);
        if ($command_result) {
            $events = json_decode($output[0]);
            $event = $events[0];
            //should have hook and should have expected_next_run.
            if (empty($event)) {
                $this->fail(
                    sprintf(
                        'The cron event hook named %s is not set.',
                        $hook
                    )
                );
            }
            if ($event->schedule !== $expected_schedule) {
                $this->fail(
                    sprintf(
                        'The actual schedule was %s.  Expected was %s.',
                        $event->next_run_gmt,
                        $expected_schedule
                    )
                );
            }
        }
    }
}