<?php

/**
 * PhpMongoAdmin (www.phpmongoadmin.com) by Masterforms Mobile & Web (MFMAW)
 * @version      ServersController.php 1001 6/8/20, 8:53 pm  Gilbert Rehling $
 * @package      PhpMongoAdmin\App
 * @subpackage   ServersController.php
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

namespace App\Http\Controllers\Api;

/**
 * Base Controllers
 */
use App\Http\Controllers\Controller;

/**
 * Requests
 */
use Illuminate\Http\Request;
use App\Http\Requests\EditServerRequest;

/**
 * Response
 */
use Illuminate\Http\Response;

/**
 * Models
 */
use App\Models\Server;
use App\Models\User;

/**
 * MongoDB connection
 */
use App\Http\Classes\MongoConnection as Mongo;
use Illuminate\Support\Facades\Crypt;


class ServersController extends Controller
{
    /**
     * @var User|null
     */
    private $user;

    /**
     * ServersController Constructor
     */
    public function __construct()
    {
        /** @var User $user */
        $this->user = auth()->guard('api')->user();

        parent::__construct($this->user, new Mongo($this->user));
    }

    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index(): Response
    {
        if ($this->isControlUser()) {
            return response()->success('success', array('servers' => Server::all()));
        }
        return response()->success('success', array('servers' => $this->user->servers()->get()));
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param   EditServerRequest $request
     * @return  Response
     */
    public function store(EditServerRequest $request): Response
    {
        $data = $request->validated();

        if (empty($data['id'])) {
            // new server
            $server         = new Server();

        } else {
            // update server
            $server         = Server::where('id', $data['id'])->get()[0];
        }

        $server->host       = $data['host'];
        $server->port       = $data['port'];
        $server->username   = $data['username'];
        if (!empty($data['password'])) {
            $server->password   = Crypt::encryptString($data['password']);
        }
        if (!empty($data['mongo_cloud'])) {
            $server->mongo_cloud = (int)$data['mongo_cloud'];
        }
        if (!empty($data['mongo_cloud_database'])) {
            // non 'admin' mongodb atlas users need to connect to a database
            $server->mongo_cloud_database = $data['mongo_cloud_database'];
        }
        $server->active     = $data['active'];
        $server->user_id    = $this->user->getAttribute('id');
        $server->save();

        return response()->success('success', array( 'server' => $server));
    }

    /**
     * Activate a server || deactivate any active server
     *
     * @param   EditServerRequest $request
     * @return  Response
     */
    public function activate(Request $request)
    {
        $id           = $request->get('id', false);
        $servers      = Server::all();
        $updateServer = null;
        foreach ($servers as $server) {
            if ("1" === $server->active && $id != $server->id) {
                /** @var Server $update */
                $update         = Server::where('id', $server->id)->get()[0];
                $update->setAttribute('active', 0);
                $update->save();
            }
            if ($id == $server->id) {
                /** @var User $updateServer */
                $updateServer = $server;
            }
        }
        if ($updateServer) {
            $updateServer = Server::where('id', $updateServer->id)->get()[0];
            $updateServer->setAttribute('active', 1);
            $updateServer->save();
            return response()->success('success', array('server' => $updateServer));
        }
        return response()->error('failed', array('error' => 'Unable to find server to activate'));
    }

    /**
     * ToDo: We are handling updates with the store method
     * Update the specified resource in storage.
     *
     * @param   Request $request
     * @param   Server $server
     * @return  void
     */
    public function update(Request $request, Server $server)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param   Server $server
     * @param   int $id
     * @return  Response
     */
    public function destroy(Server $server, int $id): Response
    {
        $result = 'failed';
        if ($id) {
            $result = Server::where('id', $id)->delete();
        }
        return response()->success('success', array('deleted' => $result));
    }
}
