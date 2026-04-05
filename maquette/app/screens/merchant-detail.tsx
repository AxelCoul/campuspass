import { useParams, useNavigate } from 'react-router';
import { mockMerchants, mockOffers } from '../data/mockData';
import { ArrowLeft, MapPin, Clock, ExternalLink } from 'lucide-react';
import { ImageWithFallback } from '../components/figma/ImageWithFallback';

export function MerchantDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  
  const merchant = mockMerchants.find(m => m.id === id);
  
  if (!merchant) {
    return (
      <div className="flex items-center justify-center h-screen">
        <p className="text-gray-500">Commerce non trouvé</p>
      </div>
    );
  }

  const merchantOffers = mockOffers.filter(offer => 
    merchant.offers.includes(offer.id)
  );

  return (
    <div className="pb-20 bg-gray-50 min-h-screen">
      {/* Header avec image */}
      <div className="relative">
        <ImageWithFallback
          src={merchant.bannerImage}
          alt={merchant.name}
          className="w-full h-48 object-cover"
        />
        
        {/* Back button */}
        <button
          onClick={() => navigate(-1)}
          className="absolute top-4 left-4 w-10 h-10 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center shadow-lg hover:bg-white transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>

        {/* Logo overlay */}
        <div className="absolute -bottom-8 left-5">
          <div className="w-20 h-20 bg-white rounded-2xl shadow-lg flex items-center justify-center text-4xl border-4 border-white">
            {merchant.logo}
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="px-5 pt-12">
        {/* Info principale */}
        <div className="mb-6">
          <h1 className="text-2xl font-bold mb-2">{merchant.name}</h1>
          <p className="text-sm text-gray-600 mb-1">
            {merchant.categoryIcon} {merchant.category} · {merchant.subcategory}
          </p>
          <p className="text-sm text-gray-500">
            📍 {merchant.location} · {merchant.distance} km
          </p>
        </div>

        {/* Bloc infos pratiques */}
        <div className="bg-white rounded-2xl p-4 mb-6 shadow-sm">
          <h2 className="font-semibold text-base mb-3">Informations pratiques</h2>
          
          <div className="space-y-3">
            {/* Adresse */}
            <div className="flex items-start gap-3">
              <MapPin className="w-5 h-5 text-gray-400 flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <p className="text-sm font-medium">Adresse</p>
                <p className="text-sm text-gray-600">{merchant.address}</p>
              </div>
            </div>

            {/* Horaires */}
            <div className="flex items-start gap-3">
              <Clock className="w-5 h-5 text-gray-400 flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <p className="text-sm font-medium">Horaires</p>
                <p className="text-sm text-gray-600">{merchant.hours}</p>
              </div>
            </div>

            {/* Google Maps link */}
            <button className="w-full mt-2 h-10 bg-gray-100 hover:bg-gray-200 text-gray-800 text-sm font-medium rounded-lg flex items-center justify-center gap-2 transition-colors">
              <ExternalLink className="w-4 h-4" />
              Voir sur Google Maps
            </button>
          </div>
        </div>

        {/* Offres disponibles */}
        <div>
          <h2 className="font-semibold text-lg mb-4">
            Offres disponibles ({merchantOffers.length})
          </h2>
          
          <div className="space-y-3">
            {merchantOffers.map((offer) => (
              <div key={offer.id} className="bg-white rounded-2xl p-4 shadow-sm">
                <div className="flex gap-4">
                  {/* Image */}
                  <ImageWithFallback
                    src={offer.image}
                    alt={offer.title}
                    className="w-24 h-24 rounded-xl object-cover flex-shrink-0"
                  />
                  
                  {/* Info */}
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-base mb-1">{offer.title}</h3>
                    <p className="text-sm text-red-600 mb-2">{offer.subtitle}</p>
                    
                    <div className="flex items-baseline gap-2">
                      <span className="text-xs text-gray-400 line-through">
                        {offer.originalPrice.toLocaleString()} FCFA
                      </span>
                      <span className="text-base font-semibold text-green-600">
                        {offer.finalPrice.toLocaleString()} FCFA
                      </span>
                    </div>
                  </div>
                </div>

                {/* Bouton */}
                <button className="w-full h-10 bg-red-600 hover:bg-red-700 text-white text-sm font-medium rounded-full mt-3 transition-colors">
                  Utiliser l'offre
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
