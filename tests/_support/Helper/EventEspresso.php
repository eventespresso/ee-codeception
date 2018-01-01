<?php
namespace Helper;

// here you can define custom actions
// all public methods declared in helper class will be available in $I

use Codeception\Module\WPWebDriver;
use Facebook\WebDriver\Exception\ElementNotVisibleException;
use Facebook\WebDriver\Remote\RemoteWebElement;

class EventEspresso extends \Codeception\Module
{
    /**
     * Use this to get the Url from a given link locater.
     *
     * @param $locater
     * @return string
     * @throws ElementNotVisibleException
     * @throws \Codeception\Exception\ModuleException
     */
    public function observeLinkUrlAt($locater)
    {
        return $this->getModule('WPWebDriver')->grabAttributeFrom($locater, 'href');
    }


    /**
     * Use this to retrieve value from an input for the given locater.
     * @param $locater
     */
    public function observeValueFromInputAt($locater)
    {
        return $this->getModule('WPWebDriver')->grabValueFrom($locater);
    }


    /**
     * This grabs the text from the given locater.
     * @param $locater
     * @return mixed
     * @throws \Codeception\Exception\ModuleException
     */
    public function observeValueFromTextAt($locater)
    {
        return $this->getModule('WPWebDriver')->grabTextFrom($locater);
    }


    /**
     * Return the named config value from the WPWebDriver Module.
     * @param string $config_key
     * @return array|mixed|null
     * @throws \Codeception\Exception\ModuleException
     */
    public function getWebDriverLoginConfig($config_key='')
    {
        return $this->getModule('WPWebDriver')->_getConfig($config_key);
    }
}
