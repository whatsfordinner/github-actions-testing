from hello import handler
import json
import unittest

class HelloTestCase(unittest.TestCase):
    expect = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps(
            {
                'message': 'Hello, world!'
            }
        )
    }

    def test_hello(self):
        self.assertDictEqual(HelloTestCase.expect, handler(None, None))

if __name__ == '__main__':
    unittest.main()