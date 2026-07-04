import sys
import os
import json
import unittest
from unittest.mock import patch, mock_open, MagicMock

sys.path.append(os.path.dirname(__file__))
import feverdream_order

class TestFeverdreamOrder(unittest.TestCase):
    @patch('feverdream_order.api_get')
    @patch('feverdream_order.api_post')
    @patch('feverdream_order.Path.exists', return_value=True)
    @patch('builtins.open', new_callable=mock_open, read_data='{"private_key": "mock_priv", "address": "mock_address"}')
    @patch('feverdream_order.RustChainWallet')
    @patch('sys.argv', ['feverdream_order.py', '--prompt', 'test prompt', '--seconds', '6', '--wallet', 'wallet.json'])
    def test_order_flow(self, mock_wallet_cls, mock_file, mock_exists, mock_post, mock_get):
        # Mock wallet instance
        mock_wallet = MagicMock()
        mock_wallet.address = "mock_address"
        mock_wallet.sign_transaction.return_value = {
            "from_address": "mock_address",
            "to_address": "feverdream_studio",
            "amount_rtc": 0.014,
            "nonce": "1234",
            "signature": "mock_sig",
            "public_key": "mock_pub"
        }
        mock_wallet_cls.from_private_key.return_value = mock_wallet

        # Mock API responses
        mock_get.return_value = {"price_per_6s": 0.014}
        mock_post.return_value = {"order_id": "test_order_id", "watch_url": "http://bottube.ai/watch/test_order_id"}

        # Run main
        with patch('builtins.print') as mock_print:
            result = feverdream_order.main()
            self.assertEqual(result, 0)
            
            # Check post payload
            mock_post.assert_called_with("/api/feverdream/order", {
                "prompt": "test prompt",
                "duration": 6,
                "payer_address": "mock_address",
                "transfer": {
                    "from_address": "mock_address",
                    "to_address": "feverdream_studio",
                    "amount_rtc": 0.014,
                    "nonce": "1234",
                    "signature": "mock_sig",
                    "public_key": "mock_pub"
                }
            })

if __name__ == "__main__":
    unittest.main()
