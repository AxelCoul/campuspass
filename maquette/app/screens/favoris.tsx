import { OfferCard } from '../components/offer-card';
import { mockOffers } from '../data/mockData';
import { Heart } from 'lucide-react';

export function Favoris() {
  // For demo purposes, show first 2 offers as favorites
  const favoriteOffers = mockOffers.slice(0, 2);

  return (
    <div className="pb-20 bg-gray-50 min-h-screen">
      {/* Header */}
      <div className="bg-white px-5 pt-12 pb-6 shadow-sm">
        <h1 className="text-2xl font-bold">Mes Favoris</h1>
        <p className="text-sm text-gray-500 mt-1">
          Retrouve toutes tes offres préférées
        </p>
      </div>

      {/* Content */}
      <div className="px-5 py-6">
        {favoriteOffers.length > 0 ? (
          <div className="flex gap-4 flex-wrap">
            {favoriteOffers.map((offer) => (
              <OfferCard key={offer.id} offer={offer} />
            ))}
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center py-20">
            <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <Heart className="w-10 h-10 text-gray-300" />
            </div>
            <p className="text-gray-500 text-center">
              Aucune offre favorite pour le moment
            </p>
            <p className="text-sm text-gray-400 text-center mt-2">
              Ajoute des offres à tes favoris pour les retrouver ici
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
