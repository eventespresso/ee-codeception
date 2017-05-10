<?php
namespace EventEspresso\Codeception\commands;

use Codeception\CustomCommandInterface;
use Mustache_Engine;
use Symfony\Component\Config\Exception\FileLoaderLoadException;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Yaml\Yaml;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Input\InputOption;

class BuildEETests extends Command implements CustomCommandInterface
{

    /**
     * Holds the config read from the yaml.
     * @var bool
     */
    protected $config = array();


    /**
     * @var OutputInterface;
     */
    protected $output;


    /**
     * @var InputInterface;
     */
    protected $input;

    /**
     * returns the name of the command
     *
     * @return string
     */
    public static function getCommandName()
    {
        return 'build_ee';
    }



    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $config_file = $input->getFirstArgument();

        $this->output = $output;
        $this->input = $input;

        //if there is no file or the given path doesn't exist get out
        if (
            empty($config_file)
            || ! is_readable($config_file)
        ) {
            $this->output->writeln('There is no yaml config file to parse.');
            return;
        }

        //have a config file now let's do the yaml
        $this->config = Yaml::parse(file_get_contents($config_file));
        $this->registerPluginsForInstall();
        $this->buildHelperTrait();
    }


    /**
     * This reads from the 'external_plugins` config option in the yaml and sets an environment variable
     * for the plugins that the install script can then use.
     *
     * The yaml should have this format:
     *
     * external_plugins:
     *   - plugin_a
     *   - plugin_b
     */
    protected function registerPluginsForInstall()
    {
        if (! isset($this->config['external_plugins'])) {
            $this->output->writeln('There are no external plugins defined for registration so this step is skipped.');
        }

        //assemble string for environment variable.
        $addons_to_register = '(';
        $addons_to_register .= implode(',', $this->config['external_plugins']);
        $addons_to_register .= ')';
        putenv("ADDITIONAL_PLUGINS_TO_INSTALL=$addons_to_register");
    }


    /**
     * This reads from the 'helper_traits' config option in the yaml and adds to the corresponding Helper
     * trait (either CoreActorHelper or AddOnActorHelper) for the related actor.
     *
     * The yaml should have this format:
     * helpers:
     *   addon:
     *     - Helper1
     *     - Helper2
     *   core:
     *     - Helper1
     *     - Helper2
     *
     * Note: add-ons should NOT define the core helper entry.  Whenever there is an add-on helper entry, then any core
     * entry is ignored.  Only EE core should have a definition for core helpers.
     */
    protected function buildHelperTrait()
    {
        //todo
    }

}