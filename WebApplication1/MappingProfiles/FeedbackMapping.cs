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
                .ForMember(dest => dest.MemberName, opt => opt.MapFrom(src => 
                    (src.Member != null && src.Member.User != null && !string.IsNullOrEmpty(src.Member.User.FirstName)) 
                    ? $"{src.Member.User.FirstName} {src.Member.User.LastName}".Trim() 
                    : (src.Member != null ? src.Member.User.UserName : "غير محدد")))
                .ForMember(dest => dest.CoachName, opt => opt.MapFrom(src => 
                    (src.Coach != null && src.Coach.User != null && !string.IsNullOrEmpty(src.Coach.User.FirstName)) 
                    ? $"{src.Coach.User.FirstName} {src.Coach.User.LastName}".Trim() 
                    : (src.Coach != null ? src.Coach.User.UserName : "غير محدد")))
                .ForMember(dest => dest.SessionName, opt => opt.MapFrom(src => src.Session != null ? src.Session.SessionName ?? "غير محدد" : "غير محدد"));

            CreateMap<CreateFeedbackDto, Feedback>();
            CreateMap<UpdateFeedbackDto, Feedback>();
        }
    }
}
