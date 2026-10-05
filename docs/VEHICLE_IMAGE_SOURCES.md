# Vehicle image sources

RideLanka FleetHire stores HTTPS image URLs in `dbo.vehicles.image_url`. The demo fleet uses Wikimedia Commons-hosted vehicle photographs. Runtime vehicle/booking logic does not depend on the images; JSPs provide a visual fallback if an external image is unavailable.

The URLs are source references to Wikimedia Commons media and remain subject to the individual file licenses shown on Commons. No API key is required.

Demo vehicle IDs V011-V052 are cars or passenger vans only; no motorcycle/bike type was introduced.
