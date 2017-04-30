<?php

class EventEspressoAcceptanceTester extends AcceptanceTester
{
    public function __construct(\Codeception\Scenario $scenario, $activate = true)
    {
        parent::__construct($scenario);
        if ($activate) {
            $this->ensureCoreActivated();
        }
    }


    public function ensureCoreActivated()
    {
        $I = $this;
        $I->loginAsAdmin();
        $I->amOnPluginsPage();
        $I->waitForText('Plugins');
        try {
            $I->seePluginDeactivated('event-espresso');
            $I->activatePlugin('event-espresso');
            $I->see('Welcome to Event Espresso');
            $I->logOut();
        } catch (Exception $e) {
            //do nothing except logout because its already active.
            $I->logOut();
        }
    }


    public function ensureCoreDeactivated()
    {
        $I = $this;
        $I->loginAsAdmin();
        $I->amOnPluginsPage();
        $I->waitForText('Plugins');
        try {
            $I->seePluginActivated('event-espresso');
            $I->deactivatePlugin('event-espresso');
            $I->see('Plugin deactivated');
            $I->logOut();
        } catch (Exception $e) {
            //do nothing except logout because its already deactivated.
            $I->logOut();
        }
    }


    public function logOut()
    {
        $I = $this;
        $I->moveMouseOver('#wp-admin-bar-my-account');
        $I->click("li#wp-admin-bar-logout > a.ab-item");
        $I->see("You are now logged out.");
    }
}