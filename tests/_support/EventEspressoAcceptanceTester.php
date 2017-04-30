<?php

/**
 * EventEspressoAcceptanceTester
 * This actor contains methods used for EventEspresso Core tests.
 *
 * @package EventEspresso Acceptance Tests
 * @author  Darren Ethier
 * @since   1.0.0
 */
class EventEspressoAcceptanceTester extends AcceptanceTester
{
    /**
     * EventEspressoAcceptanceTester constructor.
     * By default, implementing this actor will ensure that the EventEspresso core plugin is active.
     * You can control that by instantiating it with the `$activate` flag set to false.
     *
     * @param \Codeception\Scenario $scenario
     * @param bool                  $activate
     */
    public function __construct(\Codeception\Scenario $scenario, $activate = true)
    {
        parent::__construct($scenario);
        if ($activate) {
            $this->ensureCoreActivated();
        }
    }


    /**
     * Ensures the Event Espresso core plugin is activated.  However this will not cause any test fails.
     * @throws Exception
     */
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
            echo "Event Espresso core plugin is already active.";
            $I->logOut();
        }
    }


    /**
     * This ensures the Event Espresso core plugin is deactivated.  However this will not cause any test fails.
     * @throws Exception
     */
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
            echo "Event Espresso core plugin is already deactivated.";
            $I->logOut();
        }
    }


    /**
     * Logs out from the WordPress instance.
     * Before calling this, the actor should be logged in.
     */
    public function logOut()
    {
        $I = $this;
        $I->moveMouseOver('#wp-admin-bar-my-account');
        $I->click("li#wp-admin-bar-logout > a.ab-item");
        $I->see("You are now logged out.");
    }
}