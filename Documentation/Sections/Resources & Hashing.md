# Resources & Hashing
---

The `Locker` will lock and unlock any `Hashable` resource and it distinguishes the lock resources by the hash value, 
therefore care must be taken to create a hashing algorithm that ensure uniqueness between individual objects of the 
same type as well as the hash values between different types.

If two resources hash to the same hash value, and the two requested modes are incompatible, then the collision may 
cause spurious waits.
