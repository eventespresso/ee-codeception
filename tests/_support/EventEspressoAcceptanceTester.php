<?php

use EventEspresso\Codeception\helpers\CoreAggregate;

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
    use CoreAggregate;

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
        $this->ensurePluginActive('event-espresso', 'Welcome to Event Espresso');
    }


    /**
     * This ensures the Event Espresso core plugin is deactivated.  However this will not cause any test fails.
     * @throws Exception
     */
    public function ensureCoreDeactivated()
    {
        $this->ensurePluginDeactivated('event-espresso', 'Plugin deactivated');
    }


    /**
     * Given a plugin with the given slug, ensures that it is active.
     * @param string $plugin_slug
     * @param string $expected_text_after_activation
     * @throws Exception
     */
    public function ensurePluginActive($plugin_slug, $expected_text_after_activation)
    {
        $I = $this;
        $I->loginAsAdmin();
        $I->amOnPluginsPage();
        $I->waitForText('Plugins');
        try {
            $I->seePluginDeactivated($plugin_slug, true);
            $I->activatePlugin($plugin_slug, true);
            $I->waitForText($expected_text_after_activation);
        } catch (Exception $e) {
            //do nothing except logout because its already deactivated.
            echo "\nPlugin with the slug $plugin_slug is already active.\n";
        }
        //do nothing except logout because its already active.
        $I->logOut();
    }


    /**
     * Given a plugin with the given slug, ensures that it is deactivated.
     * @param $plugin_slug
     * @param $expected_text_after_deactivation
     * @throws Exception
     */
    public function ensurePluginDeactivated($plugin_slug, $expected_text_after_deactivation)
    {
        $I = $this;
        $I->loginAsAdmin();
        $I->amOnPluginsPage();
        $I->waitForText('Plugins');
        try {
            $I->seePluginActivated($plugin_slug, true);
            $I->deactivatePlugin($plugin_slug, true);
            $I->see($expected_text_after_deactivation);
        } catch (Exception $e) {
            //do nothing except logout because its already deactivated.
            echo "\nPlugin with the slug $plugin_slug is already deactivated.\n";
        }
        $I->logOut();
    }


    /**
     * Logs out from the WordPress instance.
     * Before calling this, the actor should be logged in.
     */
    public function logOut()
    {
        $I = $this;
        $I->moveMouseOver('#wp-admin-bar-my-account');
        $I->waitForElement("li#wp-admin-bar-logout > a.ab-item");
        $I->see('Log Out', '.ab-item');
        $I->click("li#wp-admin-bar-logout > a.ab-item");
        $I->see("You are now logged out.");
    }


    /**
     * Overriding default WPBrowser::activatePlugin() method because it requires an exact match for plugin slug.
     * I want to do a partial match (which will work with our version specific slugs)
     *
     * @param array|string $pluginSlug
     * @param bool         $exact   Whether to do an exact match for the slug or partial match on the start of the slug.
     */
    public function activatePlugin($pluginSlug, $exact = false)
    {
        $plugins = (array)$pluginSlug;
        foreach ($plugins as $plugin) {
            $option = $exact
                ? '//*[@data-slug="' . $plugin . '"]/th/input'
                : "//tr[starts-with(@data-slug,'$plugin')]/th/input";
            $this->scrollTo($option, 0, -40);
            $this->checkOption($option);
        }
        $this->scrollTo('select[name="action"]', 0, -40);
        $this->selectOption('action', 'activate-selected');
        $this->click("#doaction");
    }


    /**
     * Overriding default WPBrowser::deactivatePlugin() method because it requires an exact match for plugin slug.
     * I want to do a partial match (which will work with our version specific slugs)
     *
     * @param array|string $pluginSlug
     * @param bool         $exact   Whether to do an exact match for the slug or partial match on the start of the slug.
     */
    public function deactivatePlugin($pluginSlug, $exact = false) {
        $plugins = (array) $pluginSlug;
        foreach ($plugins as $plugin) {
            $option = $exact
                ? '//*[@data-slug="' . $plugin . '"]/th/input'
                : "//tr[starts-with(@data-slug,'$plugin')]/th/input";
            $this->scrollTo($option, 0, -40);
            $this->checkOption($option);
        }
        $this->scrollTo('select[name="action"]', 0, -40);
        $this->selectOption('action', 'deactivate-selected');
        $this->click("#doaction");
    }


    /**
     * Overriding default WPBrowser::seePluginActivated() method because it requires an exact match for plugin slug.
     * I want to do a partial match (which will work with our version specific slugs)
     *
     * @param array|string $pluginSlug
     * @param bool         $exact   Whether to do an exact match for the slug or partial match on the start of the slug.
     */
    public function seePluginActivated($pluginSlug, $exact = false)
    {
        $this->seePluginInstalled($pluginSlug, $exact);
        if ($exact) {
            $this->seeElement("table.plugins tr[data-slug='$pluginSlug'].active");
        } else {
            $this->seeElement("//tr[@class='active' and starts-with(@data-slug, '$pluginSlug')]");
        }
    }


    /**
     * Overriding default WPBrowser::seePluginDeactivated() method because it requires an exact match for plugin slug.
     * I want to do a partial match (which will work with our version specific slugs)
     *
     * @param array|string $pluginSlug
     * @param bool         $exact   Whether to do an exact match for the slug or partial match on the start of the slug.
     */
    public function seePluginDeactivated($pluginSlug, $exact = false)
    {
        $this->seePluginInstalled($pluginSlug, $exact);
        if ($exact) {
            $this->seeElement("table.plugins tr[data-slug='$pluginSlug'].inactive");
        } else {
            $this->seeElement("//tr[@class='inactive' and starts-with(@data-slug, '$pluginSlug')]");
        }
    }

    /**
     * Overriding default WPBrowser::seePluginInstalled() method because it requires an exact match for plugin slug.
     * I want to do a partial match (which will work with our version specific slugs)
     *
     * @param array|string $pluginSlug
     * @param bool         $exact   Whether to do an exact match for the slug or partial match on the start of the slug.
     */
    public function seePluginInstalled($pluginSlug, $exact = false)
    {
        if ($exact) {
            $this->seeElement("table.plugins tr[data-slug='$pluginSlug']");
        } else {
            $this->seeElement("//tr[starts-with(@data-slug, '$pluginSlug')]");
        }
    }



    /**
     * Overriding default WPBrowser::dontSeePluginInstalled() method because it requires an exact match for plugin slug.
     * I want to do a partial match (which will work with our version specific slugs)
     *
     * @param array|string $pluginSlug
     * @param bool         $exact   Whether to do an exact match for the slug or partial match on the start of the slug.
     */
    public function dontSeePluginInstalled($pluginSlug, $exact = false)
    {
        $this->dontSeeElement("//tr[starts-with(@data-slug, '$pluginSlug')]");
    }
}