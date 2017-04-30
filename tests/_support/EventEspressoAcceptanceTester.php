<?php

class EventEspressoAcceptanceTester extends AcceptanceTester
{
    public function __construct(\Codeception\Scenario $scenario, $activate = true)
    {
        parent::__construct($scenario);
        if ($activate) {
            $this->activateCore();
        }
    }


    public function activateCore()
    {
        $I = $this;
        $I->wantTo('Activate Event Espresso Core');
        $I->loginAsAdmin();
        $I->amOnPluginsPage();
        $I->waitForText('Plugins');
        $I->seePluginDeactivated('event-espresso');
        $I->activatePlugin('event-espresso');
        $I->see('Welcome to Event Espresso');
    }
}