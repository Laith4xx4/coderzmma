using AutoMapper;
using WebApplication1.Models;
using WebApplication1.DTOs;

namespace WebApplication1.MappingProfiles
{
    public class CoachProfileMapping : Profile
    {
        public CoachProfileMapping()
        {
            // ---------- Model -> Response DTO ----------
            CreateMap<CoachProfile, CoachProfileResponseDto>()
                .ForMember(dest => dest.UserName,
                    opt => opt.MapFrom(src => src.User.UserName))
                .ForMember(dest => dest.SessionsCount,
                    opt => opt.MapFrom(src => src.Sessions.Count))
                .ForMember(dest => dest.FeedbacksCount,
                    opt => opt.MapFrom(src => src.FeedbacksReceived.Count));

            // ---------- Create DTO -> Model ----------
            CreateMap<CreateCoachProfileDto, CoachProfile>()
                .ForMember(dest => dest.UserId, opt => opt.Ignore()) // ⭐ مهم جداً
                .ForMember(dest => dest.User, opt => opt.Ignore())
                .ForMember(dest => dest.Sessions, opt => opt.Ignore())
                .ForMember(dest => dest.FeedbacksReceived, opt => opt.Ignore());

            // ---------- Update DTO -> Model ----------
            CreateMap<UpdateCoachProfileDto, CoachProfile>()
                .ForMember(dest => dest.UserId, opt => opt.Ignore())
                .ForMember(dest => dest.User, opt => opt.Ignore());
        }
    }
}
