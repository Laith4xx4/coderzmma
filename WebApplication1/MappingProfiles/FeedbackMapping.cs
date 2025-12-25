using AutoMapper;
using WebApplication1.Models;
using WebApplication1.DTOs;

namespace WebApplication1.MappingProfiles
{
    public class FeedbackMapping : Profile
    {
        public FeedbackMapping()
        {
            CreateMap<Feedback, FeedbackResponseDto>()
                .ForMember(dest => dest.MemberName, opt => opt.MapFrom(src => src.Member.User.UserName ?? "غير محدد"))
                .ForMember(dest => dest.CoachName, opt => opt.MapFrom(src => src.Coach.User.UserName ?? "غير محدد"))
                .ForMember(dest => dest.SessionName, opt => opt.MapFrom(src => src.Session != null ? src.Session.SessionName ?? "غير محدد" : "غير محدد"));

            CreateMap<CreateFeedbackDto, Feedback>();
            CreateMap<UpdateFeedbackDto, Feedback>();
        }
    }
}
