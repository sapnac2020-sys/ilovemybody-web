import unittest

from ilmb_sync.drive import DriveReader


class DriveDiscoveryQueryTests(unittest.TestCase):
    def test_shared_with_me_mode(self):
        self.assertEqual(
            DriveReader.discovery_query("sharedWithMe"),
            "sharedWithMe = true and trashed = false",
        )

    def test_folder_mode(self):
        self.assertEqual(
            DriveReader.discovery_query("1Yp6LqzebpXKTp9hRV6IQWD7pxmrvM6qk"),
            "'1Yp6LqzebpXKTp9hRV6IQWD7pxmrvM6qk' in parents and trashed = false",
        )

    def test_invalid_folder_id_is_rejected(self):
        with self.assertRaises(ValueError):
            DriveReader.discovery_query("folder' or trashed = false")


if __name__ == "__main__":
    unittest.main()
