<?php

/**
 * EventEspressoAddonAcceptanceTester
 * This actor contains methods used for EventEspresso add-on acceptance tests.
 *
 * @package EventEspresso Acceptance Tests
 * @author  Darren Ethier
 * @since   1.0.0
 */
class EventEspressoAddonAcceptanceTester extends EventEspressoAcceptanceTester
{

    use \EventEspresso\Codeception\helpers\AddonAggregate;

    /**
     * Will hold the slug for the add-on sent in on construct.
     * Should be something like eea-people-addon
     */
    protected $addon_slug = '';

    /**
     * EventEspressoAddonAcceptanceTester constructor.
     * By default, implementing this actor will ensure that the EventEspresso core plugin and the given add-on is
     * activated.
     * You can control default behaviour that by instantiating it with the `$activate` flag set to false.
     *
     *
     * @param \Codeception\Scenario $scenario
     * @param string                $addon_slug  Required to know what add-on to activate.  Should be the something like
     *                                           eea-people-addon
     * @param bool                  $activate
     * @throws Exception
     */
    public function __construct(\Codeception\Scenario $scenario, $addon_slug, $activate = true)
    {
        $this->addon_slug = $addon_slug;
        parent::__construct($scenario, $activate);
        if ($activate) {
            $this->ensureAddonActivated();
        }
    }


    /**
     * Ensures the Event Espresso add-on is activated.  However this will not cause any test fails.
     * @throws Exception
     */
    public function ensureAddonActivated()
    {
        $I = $this;
        $I->loginAsAdmin();
        $I->amOnPluginsPage();
        $I->waitForText('Plugins');
        try {
            $I->seePluginDeactivated($this->addon_slug);
            $I->activatePlugin($this->addon_slug);
        } catch (Exception $e) {
            //do nothing except logout because its already active.
            printf("\nThe addon with the slug %s is already active.\n", $this->addon_slug);
        }
        $I->logOut();
    }


    /**
     * This ensures the Event Espresso add-on is deactivated.  However this will not cause any test fails.
     * @throws Exception
     */
    public function ensureAddonDeactivated()
    {
        $I = $this;
        $I->loginAsAdmin();
        $I->amOnPluginsPage();
        $I->waitForText('Plugins');
        try {
            $I->seePluginActivated($this->addon_slug);
            $I->deactivatePlugin($this->addon_slug);
            $I->see('Plugin deactivated');
        } catch (Exception $e) {
            //do nothing except logout because its already deactivated.
            printf("\nThe addon with the slug %s is already deactivated.\n", $this->addon_slug);
        }
        $I->logOut();
    }
}