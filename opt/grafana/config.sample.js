/** @scratch /configuration/config.js/1
 * == Configuration
 * config.js is where you will find the core Grafana configuration. This file contains parameter that
 * must be set before Grafana is run for the first time.
 */
define(['settings'],
function (Settings) {


  return new Settings({

    /**
     * elasticsearch url:
     * For Basic authentication use: http://username:password@domain.com:9200
     * elasticsearch: "http://"+window.location.hostname+":9200",
     */

    /**
     * graphite-web url:
     * For Basic authentication use: http://username:password@domain.com
     * Basic authentication requires special HTTP headers to be configured
     * in nginx or apache for cross origin domain sharing to work (CORS).
     * Check install documentation on github
     *
     *graphiteUrl: "http://"+window.location.hostname+":80/graphite-api",
     */
    datasources: {
        graphite: {
            type: 'graphite',
            url: "http://"+window.location.hostname+":80/graphite-api",
            default: true
        },
        elasticsearch: {
            type: 'elasticsearch',
            url: "http://"+window.location.hostname+":9200",
            index: 'grafana-dash',
            grafanaDB: true,
       }
    },

    default_route: '/dashboard/file/default.json',

    /**
     * If you experiance problems with zoom, it is probably caused by timezone diff between
     * your browser and the graphite-web application. timezoneOffset setting can be used to have Grafana
     * translate absolute time ranges to the graphite-web timezone.
     * Example:
     *   If TIME_ZONE in graphite-web config file local_settings.py is set to America/New_York, then set
     *   timezoneOffset to "-0500" (for UTC - 5 hours)
     * Example:
     *   If TIME_ZONE is set to UTC, set this to "0000"
     */

    timezoneOffset: null,

    /**
     * Elasticsearch index for storing dashboards
     *
     */
    grafana_index: "grafana-dash",

    /**
     * set to false to disable unsaved changes warning
     */
    unsaved_changes_warning: true,

    panel_names: [
      'text',
      'graphite'
    ]
  });
});
