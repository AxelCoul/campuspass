import { useState } from 'react';
import { OfferCard } from '../components/offer-card';
import { mockOffers } from '../data/mockData';
import { Wallet } from 'lucide-react';

export function Home() {
  const [favorites, setFavorites] = useState<string[]>([]);

  const handleUseOffer = (offerId: string) => {
    console.log('Using offer:', offerId);
    // Add to favorites for demo
    if (!favorites.includes(offerId)) {
      setFavorites([...favorites, offerId]);
    }
  };

  return (
    <div className="pb-20 bg-gray-50 min-h-screen">
      {/* Header */}
      <div className="bg-gradient-to-br from-red-600 to-red-700 text-white px-5 pt-12 pb-6">
        <div className="flex items-center justify-between mb-6">
          <div>
            <p className="text-sm opacity-90">Bonjour,</p>
            <h1 className="text-2xl font-bold mt-1">Étudiant PASS CAMPUS</h1>
          </div>
          <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
            <span className="text-2xl">👤</span>
          </div>
        </div>

        {/* Solde Card */}
        <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-4">
          <div className="flex items-center gap-2 mb-2">
            <Wallet className="w-5 h-5" />
            <span className="text-sm opacity-90">Solde disponible</span>
          </div>
          <p className="text-3xl font-bold">125 000 FCFA</p>
        </div>
      </div>

      {/* Content */}
      <div className="px-5 py-6">
        {/* Section Offres populaires */}
        <div className="mb-8">
          <h2 className="text-xl font-bold mb-4">Offres populaires</h2>
          <div className="flex gap-4 overflow-x-auto pb-2 -mx-5 px-5 scrollbar-hide">
            {mockOffers.slice(0, 4).map((offer) => (
              <OfferCard key={offer.id} offer={offer} onUse={handleUseOffer} />
            ))}
          </div>
        </div>

        {/* Section Près de toi */}
        <div>
          <h2 className="text-xl font-bold mb-4">Près de toi</h2>
          <div className="flex gap-4 overflow-x-auto pb-2 -mx-5 px-5 scrollbar-hide">
            {mockOffers.slice(4).map((offer) => (
              <OfferCard key={offer.id} offer={offer} onUse={handleUseOffer} />
            ))}
          </div>
        </div>
      </div>

      <style>{`
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
        .scrollbar-hide {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
    </div>
  );
}
