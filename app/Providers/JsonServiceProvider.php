<?php
/**
 * PhpMongoAdmin (www.phpmongoadmin.com) by Masterforms Mobile & Web (MFMAW)
 * @version      JsonServiceProvider.php 1001 6/8/20, 8:53 pm  Gilbert Rehling $
 * @package      PhpMongoAdmin\App
 * @subpackage   JsonServiceProvider.php
 * @link         https://github.com/php-mongo/admin PHP MongoDB Admin
 * @copyright    Copyright (c) 2020. Gilbert Rehling of MMFAW. All rights reserved. (www.mfmaw.com)
 * @licence      PhpMongoAdmin is an Open Source Project released under the GNU GPLv3 license model.
 * @author       Gilbert Rehling:  gilbert@phpmongoadmin.com (www.gilbert-rehling.com)
 *  php-mongo-admin - License conditions:
 *  Contributions to our suggestion box are welcome: https://phpmongotools.com/suggestions
 *  This web application is available as Free Software and has no implied warranty or guarantee of usability.
 *  See licence.txt for the complete licensing outline.
 *  See https://www.gnu.org/licenses/license-list.html for information on GNU General Public License v3.0
 *  See COPYRIGHT.php for copyright notices and further details.
 */

/**
 * Customise the JSON responses
 */

namespace App\Providers;

/**
 * @uses
 */
use Illuminate\Support\ServiceProvider;
use Illuminate\Routing\ResponseFactory;

/**
 * Class JsonServiceProvider
 *
 * @package App\Providers
 */
class JsonServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap the application
     *
     * @param ResponseFactory $factory
     *
     * @return void
     */
    public function boot(ResponseFactory $factory)
    {
        /*
         * Handle success responses
         */
        $factory->macro('success', function($message = '', $data = null, $status = 200) use ($factory) {
            $format = [
                'status' => 'ok',
                'success' => true,
                'message' => $message,
                'data' => $data
            ];
            return $factory->make($format, $status);
        });

        /*
         * Handle errors
         */
        $factory->macro('error', function($message = '', $errors = [], $status = 400) use ($factory) {
            $format = [
                'status' => 'ok',
                'success' => false,
                'message' => $message,
                'errors' => $errors
            ];
            return $factory->make($format, $status);
        });
    }

    /**
     * Register the application
     *
     * @return void
     */
    public function register()
    {
        //
    }
}
