<?php

declare(strict_types=1);

namespace App\Tests\Functional\Controller;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Symfony\Component\HttpFoundation\Request;

final class HealthCheckActionTest extends WebTestCase
{
    public function test_request_response_successfully(): void
    {
        // arrange
        $client = self::createClient();

        // act
        $router = self::getContainer()->get('router');
        $client->request(Request::METHOD_GET, $router->generate('healthcheck'));

        // assert
        self::assertResponseIsSuccessful();
        $jsonResponse = json_decode($client->getResponse()->getContent(), true);
        self::assertEquals('OK', $jsonResponse['status']);
    }
}
