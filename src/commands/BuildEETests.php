<?php
namespace EventEspresso\Codeception\commands;

use Codeception\CustomCommandInterface;
use Mustache_Engine;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Yaml\Yaml;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Codeception\Configuration;
use Symfony\Component\Console\Input\InputArgument;

class BuildEETests extends Command implements CustomCommandInterface
{

    /**
     * Holds the config read from the yaml.
     * @var array
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
     * @var Filesystem
     */
    protected $filesystem;


    /**
     * The project path for this install.
     * @var string
     */
    protected $project_path;


    /**
     * @var Mustache_Engine
     */
    protected $mustache;

    /**
     * returns the name of the command
     *
     * @return string
     */
    public static function getCommandName()
    {
        return 'build_ee';
    }


    protected function configure()
    {
        $this->vars = [];
        $this->setName('build_ee')
            ->setDescription('Sets up helper traits for EE acceptance test setup.')
            ->addArgument('config_path', InputArgument::REQUIRED, 'Path to the ee-codeception.yml file');
        parent::configure();
    }


    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $this->filesystem = new FileSystem;
        $this->mustache = new Mustache_Engine;
        $this->project_path = Configuration::projectDir();
        $config_file = $input->getArgument('config_path');
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
        $this->buildHelperTrait();
        $this->output->writeln('Succesfully ran ee test builder.');
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
        //if we have an addon config for helpers, then we just use that.
        if (array_key_exists('addon', $this->config)) {
            $this->buildAddonHelperTraits();
        } else {
            $this->buildCoreHelperTraits();
        }
    }


    /**
     * Builds import statements for traits and adds that to the `AddonAggregate.php` trait.
     */
    protected function buildAddonHelperTraits()
    {
        if (! array_key_exists('addon', $this->config)) {
            return;
        }
        $import_statements = $this->buildImportStatements($this->config['addon']);
        if ($import_statements || $import_statements === '') {
            $this->writeHelperTemplateToFile(
                'AddonAggregate',
                $import_statements
            );
        }
    }



    protected function buildCoreHelperTraits()
    {
        if (! isset($this->config['core'])) {
            return;
        }
        $import_statements = $this->buildImportStatements($this->config['core']);
        if ($import_statements) {
            $this->writeHelperTemplateToFile(
                'CoreAggregate',
                $import_statements
            );
        }
    }


    /**
     * @param string $file_name_without_extension
     * @param string $import_statements
     * @throws \Symfony\Component\Filesystem\Exception\IOException
     */
    protected function writeHelperTemplateToFile($file_name_without_extension, $import_statements)
    {
        $this->filesystem->dumpFile(
            $this->project_path . 'src/helpers/' . $file_name_without_extension . '.php',
            $this->mustache->render(
                file_get_contents(
                    $this->project_path . 'src/templates/' . $file_name_without_extension . '.mustache'
                ),
                array(
                    'imported_traits' => $import_statements
                )
            ),
            null
        );
    }


    /**
     * @param $helpers
     * @return string
     */
    protected function buildImportStatements($helpers)
    {
        $helpers = (array) $helpers;
        if (! $helpers) {
            return '';
        }
        //assemble the statements to add to our aggregate trait.
        $import_statements = 'use ' . $helpers[0] . ";\n";
        unset($helpers[0]);
        if ($helpers) {
            foreach ($helpers as $helper) {
                $import_statements .= '    use ' . $helper . ";\n";
            }
        }
        return $import_statements;
    }

}